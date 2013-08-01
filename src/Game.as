package  
{
	import customEvents.RestartEvent;
	import starling.display.Sprite;
	import starling.events.Event;
	import customEvents.NavigationEvent;
	import starling.display.Stage;
	
	/**
	 * ...
	 * @author Solveig Hansen
	 */
	public class Game extends Sprite 
	{
		private var startMenu:StartMenu;
		private var deck:Deck;
		private var rulesMenu:RulesMenu;
		private var aboutMenu:AboutMenu;
		private var ingameRules:InGameRulesPopup;
		
		public function Game() 
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			this.addEventListener(NavigationEvent.CHANGE_SCREEN, OnChangeScreen);
			this.addEventListener(RestartEvent.RESTART_GAME, OnRestartGame);
			
			deck = new Deck();
			deck.Hide();
			this.addChild(deck);
			
			rulesMenu = new RulesMenu();
			rulesMenu.Hide();
			this.addChild(rulesMenu);
			
			aboutMenu = new AboutMenu();
			aboutMenu.Hide();
			this.addChild(aboutMenu);
			
			startMenu = new StartMenu();
			this.addChild(startMenu);
			startMenu.Show();
			
			ingameRules = new InGameRulesPopup();
			ingameRules.Hide();
			this.addChild(ingameRules);
			
			
			
		}
		private function OnChangeScreen(evt:NavigationEvent):void
		{
			trace("OnchangeScreen running");
			switch(evt.params.id)
			{
				case "play":
					startMenu.Hide();
					deck.Show();
					break;
				case "rules":
					startMenu.Hide();
					rulesMenu.Show();
					break;
				case "about":
					startMenu.Hide();
					aboutMenu.Show();
					break;
				case "back":
					aboutMenu.Hide();
					rulesMenu.Hide();
					startMenu.Show();
					break;
				case "ingameRules":
					ingameRules.Show();
					deck.Hide();
					break;
				case "backToGame":
					ingameRules.Hide();
					deck.Show();
					break;
				default: break;
					
			}
		}
		private function OnRestartGame(evt:RestartEvent):void
		{
			trace("On restart game");
			this.removeChild(deck, true);
			
			deck = new Deck();
			deck.Show();
			this.addChild(deck);
			
		}
		
	}

}