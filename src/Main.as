package 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import net.hires.debug.Stats;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Solveig Hansen
	 */
	[SWF(frameRate="60", backgroundColor="#d4d4d4")]
	//[SWF(width="640", height="960", frameRate="60", backgroundColor="#d4d4d4")]
	public class Main extends Sprite 
	{
		private var stats:Stats;
		private var mStarling:Starling;
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			
			mStarling = new Starling(Game, stage);
			mStarling.antiAliasing = 1;
			mStarling.start();
			
			
		}
		
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}