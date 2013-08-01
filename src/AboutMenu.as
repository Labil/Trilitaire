package  
{
	import customEvents.NavigationEvent;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import com.greensock.TweenLite;
	
	/**
	 * ...
	 * @author Solveig Hansen
	 */
	public class AboutMenu extends Sprite 
	{
		private var bg:Image;
		private var backBtn:Button;
		
		public function AboutMenu() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			trace("Welcome screen initialized!");
			
			DrawScreen();
		}
		private function onMainMenuClick(event:Event):void
		{
			var buttonClicked:Button = event.target as Button;
			if (buttonClicked == backBtn)
			{
				this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, { id:"back" }, true));
			}
		}
		private function DrawScreen():void
		{
			bg = new Image(Assets.getTexture("AboutMenuBG"));
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