package customEvents 
{
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Solveig Hansen
	 */
	public class RestartEvent extends Event 
	{
		public static const RESTART_GAME:String = "restartGame";
		public var params:Object;
		
		public function RestartEvent(type:String, _params:Object=null, bubbles:Boolean=false) 
		{
			super(type, bubbles);
			
			this.params = _params;
		}
		
	}

}