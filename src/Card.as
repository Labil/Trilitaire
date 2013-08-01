package  
{
	import starling.text.TextField;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.HAlign;
	
	/*
	 *	Part of the card game Trilitaire
	 *	written by Solveig Hansen, 2013
	 */
	public class Card extends Sprite
	{
		private var cardImage:Image; //Background with color
		private var textField:TextField; //Value
		private var outline:Image;
		private var mType:String; //Heart, Spade, Club, Diamond
		private var mValue:int; //1,2,3,4...
		private var mbFlipped:Boolean; //Is the card on the table or in the stack?
		private var mbClickable:Boolean;
		private var mRow:int;
		private var mCardBelow1:Card;
		private var mCardBelow2:Card;
		private var mCardAbove1:Card;
		private var mCardAbove2:Card;
		private var mNotifiedInt:int;
		private const cardWidth:int = 83;
		private const cardHeight:int = 120;
		private const numberWidth:int = 25;
		private const numberHeight:int = 33;

		public function Card(_type:String, _value:int)
		{
			mType = _type;
			mValue = _value;
			SetCardGraphics();
			mNotifiedInt = 0;
		}
		
		public function GetHowManyCardsOnTop():int { return mNotifiedInt; }
		public function SetClickable(_clickable:Boolean):void { mbClickable = _clickable; }
		public function GetClickable():Boolean { return mbClickable; }
		public function SetRow(_row:int):void { mRow = _row; }
		public function GetRow():int { return mRow; }
		public function GetValue():int { return mValue; }
		public function GetType():String { return mType; }
		
		public function SetCard1Below(c:Card):void { mCardBelow1 = c; }
		public function SetCard2Below(c:Card):void { mCardBelow2 = c; }
		public function SetCard1Above(c:Card):void { mCardAbove1 = c; }
		public function SetCard2Above(c:Card):void { mCardAbove2 = c; }
		public function GetCard1Below():Card { return mCardBelow1; }
		public function GetCard2Below():Card { return mCardBelow2; }
		
		public function NotifyCardRemoved():void
		{
			mNotifiedInt++;
			if(mNotifiedInt >= 2)
				SetClickable(true);
		}
		
		public function SetCardGraphics():void
		{	
				cardImage = new Image(Assets.getAtlas().getTexture("Trilitaire_Card_" + mType + "s"));
				cardImage.width = cardWidth;
				cardImage.height = cardHeight;
				this.addChild(cardImage);
				
				textField = new TextField(30, 30, String(mValue), "Arial", 20);
				textField.hAlign = HAlign.LEFT;
				textField.x = 7;
				textField.y = 5;
				this.addChild(textField);
				
				outline = new Image(Assets.getAtlas().getTexture("Trilitaire_Card_Outline"));
				outline.width = cardWidth;
				outline.height = cardHeight;
				this.addChild(outline);
				outline.visible = false;
				
		}
		public function SetSelected(b:Boolean):void
		{
			if (!b)
				outline.visible = false;
			else
				outline.visible = true;
		}
		
		

	}
	
}

