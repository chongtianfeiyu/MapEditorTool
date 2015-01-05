package application
{
	import com.frameWork.uiControls.UIMoudleManager;
	
	import application.appui.CityNodeLibaryPanel;
	import application.appui.CityNodeLibaryPanelController;
	import application.appui.CreateNewMapPanel;
	import application.appui.CreateNewMapPanelController;
	import application.appui.TopUIPanel;
	import application.appui.TopUIPanelControler;
	import application.cityNode.ui.NodeEditorPanel;
	import application.cityNode.ui.NodeEditorPanelController;
	import application.proxy.AppDataProxy;
	import application.utils.appData;
	
	import gframeWork.uiController.UserInterfaceManager;
	
	import org.puremvc.as3.patterns.facade.Facade;

	public class AppReg
	{
		
		/**
		 * 菜单栏 
		 */		
		public static const TOP_UI_PANEL:int = 1;
		
		/**
		 * 城市节点库 
		 */		
		public static const CITY_NODE_TEMP_PANEL:int = 2;
		
		/**
		 * 创建地图面版 
		 */		
		public static const CREATE_NEW_MAP:int = 201;
		
		/**
		 * 编辑城市节点的面板 
		 */		
		public static const EDITOR_CITY_NODE_PANEL:int = 301;
		
		public function AppReg() {
			installDataProxy();
			installUIMoudle(); 
			installDataMediator();
		}
		
		private function installDataProxy():void {
			Facade.getInstance().registerProxy(new AppDataProxy(AppDataProxy.NAME));
		}
		
		private function installUIMoudle():void {
			UserInterfaceManager.registerGUI(TOP_UI_PANEL,TopUIPanel,TopUIPanelControler);
			UserInterfaceManager.registerGUI(CREATE_NEW_MAP,CreateNewMapPanel,CreateNewMapPanelController);
			UserInterfaceManager.registerGUI(CITY_NODE_TEMP_PANEL,CityNodeLibaryPanel,CityNodeLibaryPanelController);
			
			UIMoudleManager.registerUIMoudle(EDITOR_CITY_NODE_PANEL,NodeEditorPanelController,NodeEditorPanel);
		}
		
		private function installDataMediator():void {
			Facade.getInstance().registerMediator(new ApplicationMediator());
		}
	}
}