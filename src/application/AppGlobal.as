package application
{
	import flash.events.EventDispatcher;

	public class AppGlobal
	{
		public static const MAP_ROW:int = 4;
		public static const MAP_COLUMN:int = 4;
		public static const MAP_MAX_W:int = /*2048;*/5000;//2048;
		public static const MAX_MAX_H:int = /*2048;*/5000;//2048;
		
		public static const GLOBAL_DISPATCH:EventDispatcher = new EventDispatcher();
		
		public function AppGlobal() {
		}
	}
}