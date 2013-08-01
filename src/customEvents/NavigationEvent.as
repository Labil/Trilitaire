package customEvents 
{
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Solveig Hansen
	 */
	public class NavigationEvent extends Event 
	{
		
		public static const CHANGE_SCREEN:String = "changeScreen";
		public var params:Object; //Eks level number, info som sendes inn til levelet
		
		public function NavigationEvent(type:String, _params:Object=null, bubbles:Boolean=false) 
		{
			//Bubbles vil si at eventen bobler hele veien oppover til øverste parent
			super(type, bubbles);
			
			this.params = _params;
		}
		
	}

}