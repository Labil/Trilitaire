package  
{
	import customEvents.NavigationEvent;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Solveig Hansen
	 */
	public class InGameRulesPopup extends Sprite 
	{
		private var bg:Image;
		private var backBtn:Button;
		
		public function InGameRulesPopup() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			DrawScreen();
		}
		private function onMainMenuClick(event:Event):void
		{
			var buttonClicked:Button = event.target as Button;
			if (buttonClicked == backBtn)
			{
				this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, { id:"backToGame" }, true));
			}
		}
		private function DrawScreen():void
		{
			bg = new Image(Assets.getTexture("RulesMenuBG"));
			this.addChild(bg);
			
			backBtn = new Button(Assets.getAtlas().getTexture("Trilitaire_Back_Button"));
			
			backBtn.x = stage.width/8;
			backBtn.y = 40;
			this.addChild(backBtn);
			
			this.addEventListener(Event.TRIGGERED, onMainMenuClick);
			
		}
		public function Show():void
		{
			this.visible = true;
		}
		
		public function Hide():void
		{
			this.visible = false;
		}
		
	}

}