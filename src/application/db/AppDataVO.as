package application.db
{
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	import feathers.themes.StyleNameFunctionTheme;
	
	import starling.utils.AssetManager;

	public class AppDataVO
	{
		/*默认的城市节点图片文件数据*/
		public var defaultNodeFileStream:ByteArray = null;
		/*默认的城市节点图片数据*/
		public var defaultNodeBitdata:BitmapData = null;
		/*城市节点的文件数据 {textureName:String,fileStream:ByteArray} */
		public var cityNodeFiles:Array = [];
		/*城市节点bitmapdata数据 {textureName:String,bitData:BitmapData}*/
		public var cityNodeBitmapdatas:Array = [];
		/*城市节点模板数据CityNodeTempVO*/
		public var cityNodeTemps:Array = [];
		/*城市节点图片的目录地址*/
		public var cityImagesUrl:String = "";
		/*大地图上的城市节点数据列表，是一个二维数组 MapCityNodeVO结构*/
		public var mapCityNodes:Array = [];
		/*大地图的文件地址*/
		public var mapFileUrl:String = "";
		/*大地图上的文件ByteArray*/
		public var mapFileStream:ByteArray = null;
		/*大地图的图片数据*/
		public var mapBit:BitmapData = null;
		//纹理集管理
		public var textureManager:AssetManager = new AssetManager();
		//当前上传给gpu和要导出的纹理集数据包
		public var texturepack:Object = null;
		//当前正在编辑的城市节点
		public var editorCityNode:CityNodeTempVO;
		//
		public var skin:StyleNameFunctionTheme;
		
		public function AppDataVO() {
			
		}
	}
}