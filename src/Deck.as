package  
{
	import customEvents.NavigationEvent;
	import customEvents.RestartEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.events.Event;
	import starling.display.Stage;
	import starling.utils.Color;
	
	public class Deck extends Sprite
	{
		private var bg:Image;
		private var restartBtn:Button;
		private var hintBtn:Button;
		private var rulesBtn:Button;
		
		private const cNumCards:int = 52;
		private const cNumRows:int = 7;
		private const cSpacingX:int = 18;
		private const cSpacingY:int = 40;
		
		private var mCards:Vector.<Card> = new Vector.<Card>(cNumCards, false); //Last parameter decides if the vector should have fixed length or not
		private var mCardStack:Vector.<Card> = new Vector.<Card>(0, false);
		private var mCardsOnTable:Vector.<Card> = new Vector.<Card>(0, false);
		private var mCardStackDealt:Vector.<Card> = new Vector.<Card>(0, false);
		
		private var selectedCard1:Card;
		private var selectedCard2:Card;
		private var mTopDeckCard:Card;
		
		private var mDealCardsButton:Button;
		private var textField:TextField;
		
		private var functionWithParams:Function;
		private var hintTimer:Timer;
		
		
		public function Deck() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, Cleanup);
			
			AddInGameMenu();
			AddDealButton();
			MakeDeck();
			ShuffleDeck(mCards);
			AddCardsToStage();
			DisplayNumberOfCardsInDeck();
			LinkCards();
		}
		public function Hide():void
		{
			this.visible = false;
			
			if (this.hasEventListener(Event.ENTER_FRAME)) 
				this.removeEventListener(Event.ENTER_FRAME, buttonAnimation);
		}
		public function Show():void
		{
			this.visible = true;
			
			this.addEventListener(Event.ENTER_FRAME, buttonAnimation);
		}
		
		//Adds the graphics and necessary eventListeners for the in-game menu.
		private function AddInGameMenu():void
		{
			bg = new Image(Assets.getTexture("GameBG"));
			this.addChild(bg);
			
			restartBtn = new Button(Assets.getAtlas().getTexture("Trilitaire_Restart_Button"));
			rulesBtn = new Button(Assets.getAtlas().getTexture("Trilitaire_Ingame_Rules_Button"));
			hintBtn = new Button(Assets.getAtlas().getTexture("Trilitaire_Hint_Button"));
			
			restartBtn.height /= 1.5;
			restartBtn.width /= 1.5;
			restartBtn.x = stage.width/4 - restartBtn.width/2;
			restartBtn.y = stage.height - (restartBtn.height + 30);
			this.addChild(restartBtn);
			
			rulesBtn.height /= 1.5;
			rulesBtn.width /= 1.5;
			rulesBtn.x = stage.width/3 + 40;
			rulesBtn.y = stage.height - (rulesBtn.height + 40);
			this.addChild(rulesBtn);
			
			hintBtn.height /= 1.5;
			hintBtn.width /= 1.5;
			hintBtn.x = stage.width/2 + 80;
			hintBtn.y = stage.height - (hintBtn.height + 40);
			this.addChild(hintBtn);
			
			this.addEventListener(Event.TRIGGERED, onButtonClick);
		}
		
		//The in-game menu button events.
		//Either restarts the game, displays the rules menu, or shows a hint.
		private function onButtonClick(event:Event):void
		{
			var buttonClicked:Button = event.target as Button;
			if (buttonClicked == restartBtn)
			{
				this.dispatchEvent(new RestartEvent(RestartEvent.RESTART_GAME, {}, true));
			}
			else if (buttonClicked == rulesBtn)
			{
				this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, { id:"ingameRules" }, true));
			}
			else if (buttonClicked == hintBtn)
			{
				ShowHint();
			}
		}
		
		//Checks to see if there are any pairs to be made among the clickable cards, as well as the top deck card. Also checks for kings.
		//If there are, the cards are outlines for 1 second before the selection resets.
		private function ShowHint():void
		{
			ResetSelection();
			if (hintTimer != null && hintTimer.running) //Aborts if a hint is currently being displayed and the timer is already running
				return; 
			for (var i:int = 0; i < mCardsOnTable.length; i++)
			{
				if (mCardsOnTable[i].GetClickable())
				{
					for (var j:int = 0; j < mCardsOnTable.length; j++)
					{
						if (mCardsOnTable[j].GetClickable())
						{
							if (mCardsOnTable[i].GetValue() + mCardsOnTable[j].GetValue() == 13)
							{
								hintTimer = new Timer(1000, 1);
								functionWithParams = clearOnTimer(mCardsOnTable[i], mCardsOnTable[j]);
								hintTimer.addEventListener(TimerEvent.TIMER, functionWithParams);
								
								mCardsOnTable[i].SetSelected(true);
								mCardsOnTable[j].SetSelected(true);
								
								hintTimer.start();
								
								return;
							}
							
						}
						else if (mTopDeckCard != null && mTopDeckCard.GetValue() + mCardsOnTable[i].GetValue() == 13)
						{
							hintTimer = new Timer(1000, 1);
							functionWithParams = clearOnTimer(mCardsOnTable[i], mTopDeckCard);
							hintTimer.addEventListener(TimerEvent.TIMER, functionWithParams);
								
							mCardsOnTable[i].SetSelected(true);
							mTopDeckCard.SetSelected(true);
								
							hintTimer.start();
								
							return;
						}
						else if (mCardsOnTable[i].GetValue() == 13)
						{
							hintTimer = new Timer(1000, 1);
							functionWithParams = clearOnTimer(mCardsOnTable[i]);
							hintTimer.addEventListener(TimerEvent.TIMER, functionWithParams);
								
							mCardsOnTable[i].SetSelected(true);
								
							hintTimer.start();
								
							return;
						}
					}
				}
			}
		}
		
		//Returns a function to the eventListener. Trick to send parameters to a listener. See example at:
		//http://stackoverflow.com/questions/13486230/to-pass-a-parameter-to-event-listener-in-as3-the-simple-way-does-it-exist
		private function clearOnTimer(c1:Card, c2:Card = null):Function  																
		{
			this.removeEventListener(TimerEvent.TIMER, functionWithParams);
			return function(t:TimerEvent):void 
			{
				c1.SetSelected(false);
				if(c2 != null)
					c2.SetSelected(false);
			}
		}
		
		//The button to click when dealing cards from the deck
		private function AddDealButton():void
		{
			mDealCardsButton = new Button(Assets.getAtlas().getTexture("Trilitaire_Card_Background"));
			mDealCardsButton.width = 83;
			mDealCardsButton.height = 120;
			this.addChild(mDealCardsButton);
			mDealCardsButton.x = 220;
			mDealCardsButton.y = 470;
			textField = new TextField(80, 40, "", "Arial",30, Color.WHITE);
			textField.x = mDealCardsButton.width / 2;
			textField.y = 150 ;
			mDealCardsButton.addChild(textField);
			mDealCardsButton.addEventListener(TouchEvent.TOUCH, DealCard);
		}
		
		private function MakeDeck():void
		{
			for(var i:int = 0; i < cNumCards; i++)
			{
				if(i < 13){ mCards[i] = new Card("Spade", i+1); }
				else if(i < 26){ mCards[i] = new Card("Club", i-13+1); }
				else if(i < 39){ mCards[i] = new Card("Heart", i-26+1); }
				else if(i < 52){ mCards[i] = new Card("Diamond", i-39+1); }
			}
		}
		
		//Keeps track of how many cards are still left in the deck
		private function DisplayNumberOfCardsInDeck():void
		{
			if(mCardStack.length > 0)
				textField.text = String(mCardStack.length);
			else
				textField.text = "Flip";
		}
		
		//Adds a card from the deck to the stage, on top of the previously dealt cards
		private function DealCard(me:TouchEvent):void
		{
			if (me.getTouch(this) != null)
			{
				if (me.getTouch(this).phase == TouchPhase.BEGAN)
				{
					if(mCardStack.length > 0)
					{
						ResetSelection();
						mTopDeckCard = mCardStack[mCardStack.length-1];				
						mTopDeckCard.x = 220 + mTopDeckCard.width + cSpacingX;
						mTopDeckCard.y = 470;
						this.addChild(mTopDeckCard);
						mTopDeckCard.addEventListener(TouchEvent.TOUCH, OnTableCardClick);
						mCardStackDealt.push(mTopDeckCard);
						mCardStack.pop();
						DisplayNumberOfCardsInDeck();
					}
					else
					{
						mCardStack.length = mCardStackDealt.length;
						for(var i:int = 0; i < mCardStack.length; i++)
						{
							mCardStack[i] = mCardStackDealt[mCardStackDealt.length-1-i];
						}
						RemoveCardsFromStage();
						DisplayNumberOfCardsInDeck();
						mCardStackDealt.length = 0;
					}
				}
				
				
			}
			
		}
		private function RemoveCardsFromStage():void
		{
			for(var j:int = 0; j < mCardStackDealt.length; j++)
			{
				for(var k:int = 0; k < this.numChildren; k++)
				{
					if(mCardStackDealt[j] == this.getChildAt(k))
					{
						this.removeChildAt(k);
					}
				}
			}
		}
		private function OnTableCardClick(me:TouchEvent):void
		{
			if (me.getTouch(this) != null)
			{
				if (me.getTouch(this).phase == TouchPhase.BEGAN)
				{
					if(selectedCard1 == null)
					{
						selectedCard1 = Card(me.currentTarget);
						if(Card(me.currentTarget).GetClickable()) //Can you click on this card or is it locked behind other cards?
						{
							selectedCard1.SetSelected(true);
							if(selectedCard1.GetValue() == 13)
							{
								if(selectedCard1.GetCard1Below() != null)
									selectedCard1.GetCard1Below().NotifyCardRemoved();
								if(selectedCard1.GetCard2Below() != null)
									selectedCard1.GetCard2Below().NotifyCardRemoved();
								if(selectedCard1 == mTopDeckCard)
								{
									mCardStackDealt.pop();
									if(mCardStackDealt.length > 0)
										mTopDeckCard = mCardStackDealt[mCardStackDealt.length-1];
									else
										mTopDeckCard = null;
								}
								else
								{
									RemoveCardFromSearchVector(selectedCard1);
								}
								this.removeChild(selectedCard1);
								selectedCard1 = null;
								
							}
						}
						else
						{
							selectedCard1 = null;
						}
					}
					else if(selectedCard2 == null)
					{
						if(me.currentTarget == selectedCard1)
						{
							ResetSelection();
						}
						else
						{
							selectedCard2 = Card(me.currentTarget);
							if(selectedCard1.GetCard1Below() == selectedCard2 || selectedCard1.GetCard2Below() == selectedCard2)
							{
								if(selectedCard2.GetHowManyCardsOnTop() == 1 && selectedCard2.GetValue() + selectedCard1.GetValue() == 13)
								{
								   selectedCard2.SetClickable(true);
								}
							}
							if(Card(me.currentTarget).GetClickable()) //Can you click on this card or is it locked behind other cards?
							{
								selectedCard2.SetSelected(true);
								if(!CheckPair())
								{
									ResetSelection();
								}
							}
							else
							{
								if(selectedCard2 != null)
									selectedCard2 = null;
							}
								
							
						}
					}
				}
			}
		}
		private function ResetSelection():void
		{
			if (selectedCard2 != null)
			{
				selectedCard2.SetSelected(false);
				selectedCard2 = null;
			}
			if (selectedCard1 != null)
			{
				selectedCard1.SetSelected(false);
				selectedCard1 = null;
			}
			
			
		}
		private function CheckPair():Boolean  //Checks the two cards to see if there's a match. Removes them if they pair up.
		{
			if(selectedCard2.GetValue() + selectedCard1.GetValue() == 13)
			{
				if(selectedCard1.GetCard1Below() != null)
					selectedCard1.GetCard1Below().NotifyCardRemoved();
				if(selectedCard1.GetCard2Below() != null)
					selectedCard1.GetCard2Below().NotifyCardRemoved();
				if(selectedCard2.GetCard1Below() != null)
					selectedCard2.GetCard1Below().NotifyCardRemoved();
				if(selectedCard2.GetCard2Below() != null)
					selectedCard2.GetCard2Below().NotifyCardRemoved();
				
				if(selectedCard2 == mTopDeckCard || selectedCard1 == mTopDeckCard)
				{
					mCardStackDealt.pop();
					if(mCardStackDealt.length > 0)
						mTopDeckCard = mCardStackDealt[mCardStackDealt.length-1];
					else
						mTopDeckCard = null;
				}
				RemoveCardFromSearchVector(selectedCard1);
				RemoveCardFromSearchVector(selectedCard2);
				this.removeChild(selectedCard1);
				this.removeChild(selectedCard2);
				ResetSelection();
				CheckWinCondition();
				return true;
			}
			return false;
		}
		private function CheckWinCondition():void
		{
			if ( mCardsOnTable.length <= 0)
			{
				trace("WIN!!!");
			}
		}
		private function RemoveCardFromSearchVector(c:Card):void
		{
			for (var i:int = 0; i < mCardsOnTable.length; i++)
			{
				if (mCardsOnTable[i] == c)
				{
					mCardsOnTable.splice(i, 1);
				}
			}
		}
		private function ShuffleDeck(vec:Vector.<Card>):void 
		{
			var i:int = vec.length;
			while(i > 0)
			{
				var j:int = Math.floor(Math.random() * i);
				i--;
				var temp:* = vec[i];
				vec[i] = vec[j];
				vec[j] = temp;
			}
		}
		
		private function PlaceCard(c:Card, _X:int, _Y:int):void
		{
			this.addChild(c);
			c.x = _X;
			c.y = _Y;
			c.SetCardGraphics();
			mCardsOnTable.push(c);
			
		}
		private function AddCardsToStage():void
		{
			var xPos:int;
			var yPos:int;
			//var stageHW:int = this.width/2;
			var stageHW:int = 320 - 83;
			
			for(var i:int = 0; i < mCards.length; i++)
			{
				xPos = stageHW;
				if(i < 1)
				{
					xPos += (mCards[i].width/2);
					yPos = cSpacingY;
					mCards[i].SetRow(1);
				}
				else if(i < 3)
				{
					xPos += (mCards[i].width*i) - (mCards[i].width *1);
					yPos = cSpacingY * 2 + 5;
					mCards[i].SetRow(2);
				}
				else if(i < 6)
				{
					xPos += (mCards[i].width*i) - (mCards[i].width*3.5);
					yPos = cSpacingY * 3 +10;
					mCards[i].SetRow(3);
				}
				else if(i < 10)
				{
					xPos += (mCards[i].width*i) - (mCards[i].width*7);
					yPos = cSpacingY * 4 +15;
					mCards[i].SetRow(4);
				}
				else if(i < 15)
				{
					xPos += (mCards[i].width*i) - (mCards[i].width*11.5);
					yPos = cSpacingY * 5 +20;
					mCards[i].SetRow(5);
				}
				else if(i < 21)
				{
					xPos += (mCards[i].width*i) - (mCards[i].width*17);
					yPos = cSpacingY * 6+25;
					mCards[i].SetRow(6);
				}
				else if(i < 28)
				{
					xPos += (mCards[i].width*i) - mCards[i].width*23.5;
					yPos = cSpacingY * 7+30;
					mCards[i].SetRow(7);
					mCards[i].SetClickable(true);
				}
				if(i < 28)
				{
					mCards[i].addEventListener(TouchEvent.TOUCH, OnTableCardClick);
					PlaceCard(mCards[i], xPos, yPos);
				}
				else
				{
					mCards[i].SetClickable(true);
					mCardStack.push(mCards[i]);
				}
				
			}
		}
		private function LinkCards():void
		{
			for(var i:int = 0; i < 28; i++)
			{
				if(i == 0)
				{
					//mCards[i].SetCard1Above(mCards[i + mCards[i].GetRow()]);
					//mCards[i].SetCard2Above(mCards[i + mCards[i].GetRow() + 1];
					continue;
				}
				else if(mCards[i].GetRow() == 7)
				{
					if(i == 21)
						mCards[i].SetCard1Below(mCards[i - mCards[i].GetRow() + 1]);
					if(i == 27)
						mCards[i].SetCard1Below(mCards[i - mCards[i].GetRow()]);
					else
					{
						mCards[i].SetCard1Below(mCards[i - mCards[i].GetRow() + 1]);
						mCards[i].SetCard2Below(mCards[i - mCards[i].GetRow()]);
					}
				}
				else
				{
					if(mCards[i].GetRow() != mCards[i-1].GetRow()) //Checks if this card is the first in its row
					{
						mCards[i].SetCard1Below(mCards[i - mCards[i].GetRow() + 1]);
					}
					else if(mCards[i].GetRow() != mCards[i+1].GetRow()) //Checks if this card is the last in its row
						mCards[i].SetCard1Below(mCards[i - mCards[i].GetRow()]);
					else
					{
						mCards[i].SetCard1Below(mCards[i - mCards[i].GetRow()]);
						mCards[i].SetCard2Below(mCards[i - mCards[i].GetRow() + 1]);
					}
					
						
				}
			}
		}
		
		private function buttonAnimation(evt:Event):void
		{
			var currentDate:Date = new Date();
			hintBtn.y = stage.height - (hintBtn.height + 40) + (Math.cos(currentDate.getTime() * 0.002) * 3);
			
		}
		public function Cleanup(e:Event):void
		{
			if (hintTimer != null && hintTimer.running)
				this.removeEventListener(TimerEvent.TIMER, functionWithParams);
			if (this.hasEventListener(Event.ENTER_FRAME)) 
				this.removeEventListener(Event.ENTER_FRAME, buttonAnimation);
			if(this.hasEventListener(Event.TRIGGERED))
				this.removeEventListener(Event.TRIGGERED, onButtonClick);
			this.removeChildren();
			/*Running timers must be stopped
			'enterFrame' event listeners must be removed
			Open network connections should be closed
			Any children added to the stage must be removed
			Stage event listeners must be removed
			BitmapData objects must be disposed
			Sound playing must be stopped*/
		}

	}
	
}

