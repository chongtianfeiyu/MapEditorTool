package application.appui
{
	import com.frameWork.uiComponent.Alert;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.events.FlexEvent;
	
	import application.AppReg;
	import application.utils.ExportTexturesUtils;
	
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
			ui.btnExport.addEventListener(MouseEvent.CLICK,exportClickHandler,false,0,true);
			ui.btnExportTextures.addEventListener(MouseEvent.CLICK,exportTexturesHandler,false,0,true);
		}
		
		private function newClickHandler(event:Event):void {
			UserInterfaceManager.open(AppReg.CREATE_NEW_MAP);	
		}
		
		private function openClickHandler(event:Event):void {
			
		}
		
		private function exportClickHandler(event:Event):void {
			
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
		
		public override function dispose():void {
			super.dispose();
		}
		
		public function get ui():TopUIPanel {
			return mGUI as TopUIPanel
		}
	}
}