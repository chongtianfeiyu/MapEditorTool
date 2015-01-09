package application.mapEditor.ui
{
	import com.frameWork.gestures.DragGestures;
	import com.frameWork.uiControls.UIMoudle;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import application.AppReg;
	import application.db.CityNodeTempVO;
	import application.db.MapCityNodeVO;
	import application.mapEditor.comps.MapCityNodeComp;
	import application.utils.appData;
	
	import gframeWork.appDrag.AppDragEvent;
	import gframeWork.appDrag.AppDragMgr;
	import gframeWork.uiController.UserInterfaceManager;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	public class MapEditorPanelConstroller extends UIMoudle
	{
		private var sizeRect:Rectangle;
		
		/**
		 * 大地图城市节点信息 
		 */		
		private var mapCitys:Vector.<MapCityNodeComp>;
		
		/**
		 * 地图拖拽功能 
		 */		
		private var mapMove:DragScrollGestures;
		
		public function MapEditorPanelConstroller() {
			super();
			smartClose = false;
			mapCitys = new Vector.<MapCityNodeComp>();
		}
		
		protected override function uiCreateComplete(event:Event):void {
			super.uiCreateComplete(event);
			sizeRect = getSize();
			ui.x = left;
			ui.y = top;
			ui.setSize(sizeRect.width,sizeRect.height);
			ui.clipRect = new Rectangle(0,0,sizeRect.width,sizeRect.height);
			mapMove = new DragScrollGestures(ui.uiContent,mapDragHandler);
			mapMove.setDragRectangle(ui.clipRect,ui.uiContent.width,ui.uiContent.height);
			AppDragMgr.addEventListener(AppDragEvent.DRAG,onDragHandler);
		}
		
		//拖拽
		private function onDragHandler(event:AppDragEvent):void {
			var localPt:Point = new Point();
			ui.mapFloor.globalToLocal(event.hitPoint,localPt);
			if(ui.mapFloor.hitTest(localPt)) {
				//添加cityInfo
				var cityInfo:MapCityNodeVO = new MapCityNodeVO();
				cityInfo.textureName = CityNodeTempVO(event.itemData).textureName;
				cityInfo.worldX = localPt.x - event.offPoint.x;
				cityInfo.worldY = localPt.y - event.offPoint.y;
				createMapNode(cityInfo);
			}
		}
		
		/**
		 * 创建地图上的城市节点 
		 * @param mapNodeInfo
		 * @return 
		 */		
		public function createMapNode(mapNodeInfo:MapCityNodeVO):MapCityNodeComp {
			var city:MapCityNodeComp = new MapCityNodeComp(mapNodeInfo);
			ui.citySpace.addChild(city);
			
			city.x = mapNodeInfo.worldX;
			city.y = mapNodeInfo.worldY;
			
			mapCitys.push(city);
			appData.mapCityNodes.push(mapNodeInfo);
			return city;
		}
		
		/**
		 * 大地图拖拽回调 
		 */		
		private function mapDragHandler():void {}
		
		/**
		 * 刷地图上所有城市的显示 
		 */		
		public function refreshAllCity():void {
			var i:int = mapCitys.length;
			while(--i > -1) mapCitys[i].invalidateUpdateList();
		}
		
		private function getSize():Rectangle {
			var w:int = Starling.current.stage.stageWidth - left - right;
			var h:int = Starling.current.stage.stageHeight - top - bottom;
			return new Rectangle(left,top,w,h);
		}
		
		private function get ui():MapEditorPanel {
			return uiContent as MapEditorPanel
		}
		
		private function get right():int {
			return 200;
		}
		
		private function get bottom():int {
			return 0;
		}
		
		private function get left():int {
			return UserInterfaceManager.getUIByID(AppReg.CITY_NODE_TEMP_PANEL).getGui().width;
		}
		
		private function get top():int {
			return UserInterfaceManager.getUIByID(AppReg.TOP_UI_PANEL).getGui().height;
		}
	}
}