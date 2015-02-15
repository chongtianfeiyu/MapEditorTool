package application.appui
{
	import com.frameWork.uiComponent.Alert;
	import com.frameWork.uiControls.UIMoudleManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.events.FlexEvent;
	
	import application.AppReg;
	import application.mapEditor.ui.MapEditorPanelConstroller;
	import application.proxy.AppDataProxy;
	import application.utils.ExportTexturesUtils;
	import application.utils.appData;
	import application.utils.appDataProxy;
	
	import gframeWork.uiController.MainUIControllerBase;
	import gframeWork.uiController.UserInterfaceManager;
	
	/**
	 * 主界面上的菜单处理栏 
	 * @author JiangTao
	 */	
	public class TopUIPanelControler extends MainUIControllerBase
	{
		public function TopUIPanelControler() {
			super();
			autoClose = false;
		}
		
		protected override function uiCreateComplete(event:FlexEvent):void {
			super.uiCreateComplete(event);
			ui.btnNew.addEventListener(MouseEvent.CLICK,newClickHandler,false,0,true);
			ui.btnOpen.addEventListener(MouseEvent.CLICK,openClickHandler,false,0,true);
			ui.exportFile.addEventListener(MouseEvent.CLICK,exportClickHandler,false,0,true);
			ui.btnExportTextures.addEventListener(MouseEvent.CLICK,exportTexturesHandler,false,0,true);
			ui.saveFile.addEventListener(MouseEvent.CLICK,saveClickHandler,false,0,true);
			ui.QuickSaveFile.addEventListener(MouseEvent.CLICK,quickSaveClickHandler,false,0,true);
			ui.outputRoad.addEventListener(MouseEvent.CLICK,outputRoadHandler,false,0,true);
			ui.checkVisualAllRoad.addEventListener(Event.CHANGE,visualAllRoad,false,0,true);
		}
		
		//是否显示全部路径
		private function visualAllRoad(event:Event):void {
			appData.IS_DRAW_ALL_ROAD = ui.checkVisualAllRoad.selected;
			if(mapEditor && mapEditor.ui) {
				mapEditor.smartDrawroad();
			}
		}
		
		private function outputRoadHandler(event:MouseEvent):void {
			UserInterfaceManager.open(AppReg.ROAD_OUTPUT);
		}
		
		private function saveClickHandler(event:MouseEvent):void {
			appDataProxy.saveMapEditorFile(AppDataProxy.SAVE);
		}
		
		private function quickSaveClickHandler(event:MouseEvent):void {
			appDataProxy.saveMapEditorFile(AppDataProxy.SAVE_QUICK);
		}
		
		private function newClickHandler(event:Event):void {
			UserInterfaceManager.open(AppReg.CREATE_NEW_MAP);	
		}
		
		private function openClickHandler(event:Event):void {
			appDataProxy.openFileData();
		}
		
		private function exportClickHandler(event:Event):void {
			ExportTexturesUtils.exportToGameFile();
		}
		
		private function exportTexturesHandler(event:Event):void {
			var chrooseFolder:Function = function(event:Event):void {
				fileSelect.removeEventListener(Event.SELECT,chrooseFolder);
				if(ExportTexturesUtils.exportTextures(fileSelect.nativePath)) {
					trace("export succeed");
				}
			};
			var fileSelect:File = new File();
			fileSelect.addEventListener(Event.SELECT,chrooseFolder);
			fileSelect.browseForDirectory("选择要导出的纹理目录");
		}
		
		private function get mapEditor():MapEditorPanelConstroller {
			return UIMoudleManager.getUIMoudleByOpenId(AppReg.EDITOR_MAP_PANEL) as MapEditorPanelConstroller;
		}
		
		public override function dispose():void {
			super.dispose();
		}
		
		public function get ui():TopUIPanel {
			return mGUI as TopUIPanel
		}
	}
}