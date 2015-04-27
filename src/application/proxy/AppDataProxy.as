package application.proxy
{
	import com.frameWork.uiControls.UIMoudleManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.utils.StringUtil;
	
	import spark.components.Alert;
	
	import application.AppReg;
	import application.ApplicationMediator;
	import application.db.CityNodeVO;
	import application.db.MapCityNodeTempVO;
	import application.db.RoadPathNodeVO;
	import application.mapEditor.ui.MapEditorPanelConstroller;
	import application.utils.ExportTexturesUtils;
	import application.utils.MapUtils;
	import application.utils.appData;
	import application.utils.appDataProxy;
	import application.utils.roadDataProxy;
	
	import feathers.controls.Alert;
	
	import gframeWork.uiController.UserInterfaceManager;
	import gframeWork.url.URLFileReference;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class AppDataProxy extends Proxy
	{
		//关键字段
		public static const TEXTURE_NAME_FIELD:String = "textureName";	//纹理名称
		public static const BITMAP_DATE_FIELD:String = "bitmapData";		//位图数据
		public static const FILE_STREAM_FIELD:String = "stream";			//文件数据

		public static const SAVE:int = 0;				//另存为
		public static const SAVE_QUICK:int = 1;		//快速保存
		
		//保存文件
		private var saveFile:File;		
		
		//默认的城市节点
		private var defaultCityNodeFile:URLFileReference;
		private var defaultCityNodeLoad:Loader;
		
		/**
		 * 当前节点的装载 
		 */		
		private var nowNodeLoadCount:int = 0;
		
		public function AppDataProxy(proxyName:String=null, data:Object=null){
			super(proxyName, data);
		}
		
		public function internalInit():void {
			
			//装载默认的城市节点图片
			var loadBitmapSucceed:Function = function(event:Event):void {
				defaultCityNodeLoad.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadBitmapSucceed);
				appData.defaultNodeBitdata = Bitmap(defaultCityNodeLoad.content).bitmapData;
			};
				
			//打开默认的城市节点文件
			var openFileSucceedFun:Function = function(event:Event):void {
				appData.defaultNodeFileStream = defaultCityNodeFile.getFileStrem();
				if(!defaultCityNodeLoad) defaultCityNodeLoad = new Loader();
				defaultCityNodeLoad.contentLoaderInfo.addEventListener(Event.COMPLETE,loadBitmapSucceed);
				defaultCityNodeLoad.loadBytes(appData.defaultNodeFileStream);
			};
			
			//打开默认的城市节点图片文件
			if(!defaultCityNodeFile) defaultCityNodeFile = new URLFileReference();
			defaultCityNodeFile.openFile(openFileSucceedFun,null,null,new URLRequest("assets/default_city_node.png"));
		}
		
		/**
		 * 打开文件数据 
		 */		
		public function openFileData():void {
			var openFunc:Function = function(event:Event):void {
				UserInterfaceManager.close(AppReg.CITY_NODE_TEMP_PANEL);
				UserInterfaceManager.close(AppReg.CITY_EDIT_PROPERTIES);
				UIMoudleManager.closeUIById(AppReg.EDITOR_MAP_PANEL);
				clearAppData();
				
				var mapFileByte:ByteArray = new ByteArray();
				var fileStream:FileStream = new FileStream();
				fileStream.open(openFile,FileMode.READ);
				fileStream.readBytes(mapFileByte);
				fileStream.close();
				
				appData.cityNodeTemps = [];
				//解城市节点模板数据
				var nodeObjTemps:Array = mapFileByte.readObject() as Array;
				var i:int = 0;
				var len:int = nodeObjTemps.length;
				var nodeTemps:Array = [];
				for(i; i != len; i++) {
					var nodeTemp:MapCityNodeTempVO = new MapCityNodeTempVO();
					nodeTemp.labelX = nodeObjTemps[i][0];
					nodeTemp.labelY = nodeObjTemps[i][1];
					nodeTemp.freeX = nodeObjTemps[i][2];
					nodeTemp.freeY = nodeObjTemps[i][3];
					nodeTemp.textureName = nodeObjTemps[i][4];
					nodeTemp.flagX = nodeObjTemps[i][5];
					nodeTemp.flagY = nodeObjTemps[i][6];
					nodeTemp.menuX = nodeObjTemps[i][7];
					nodeTemp.menuY = nodeObjTemps[i][8];
					nodeTemps.push(nodeTemp);
				}
				appData.cityNodeTemps = nodeTemps;
				
				appData.mapCityNodes = [];
				//解地图上的城市实例数据
				var mapNodeObjs:Array = mapFileByte.readObject() as Array;
				var mapCityNodeData:Array = null;
				var mapCityNodes:Array = [];
				len = mapNodeObjs.length;
				for(i = 0; i != len; i++) {
					mapCityNodeData = mapNodeObjs[i];
					var mapCityNode:CityNodeVO = new CityNodeVO();
					mapCityNode.worldX = mapCityNodeData[0];
					mapCityNode.worldY = mapCityNodeData[1];
//					mapCityNode.faction = mapCityNodeData[2];
//					mapCityNode.labelX = mapCityNodeData[3];
//					mapCityNode.labelY = mapCityNodeData[4];
//					mapCityNode.freeX = mapCityNodeData[5];
//					mapCityNode.freeY = mapCityNodeData[6];
					mapCityNode.textureName = mapCityNodeData[2];
					mapCityNode.templateId = mapCityNodeData[3];
					mapCityNode.visualFiree = mapCityNodeData[4];
					mapCityNode.cityName = mapCityNodeData[5];
					mapCityNode.toCityIds = mapCityNodeData[6] ? mapCityNodeData[6] : [];
					mapCityNode.visualRaod = mapCityNodeData[7];
					mapCityNode.reversal = mapCityNodeData[8];
					mapCityNode.offsetX = mapCityNodeData[9];
					mapCityNodes.push(mapCityNode);
				}
				appData.mapCityNodes = mapCityNodes;
				
				//读取地图上的所有路径的key
				var roadKeys:Array = mapFileByte.readObject() as Array;
				appData.roadKey = roadKeys;
				
				appData.roadPathNodes = [];
				var roadNodes:Array = mapFileByte.readObject() as Array;
				var roadPahtNodes:Array = [];
				len = roadNodes.length;
				var roadPathNodeInfo:RoadPathNodeVO;
				for(i = 0; i != len; i++) {
					roadPathNodeInfo = new RoadPathNodeVO();
					roadPathNodeInfo.fromCityId = roadNodes[i][0];
					roadPathNodeInfo.toCityId = roadNodes[i][1];
					roadPathNodeInfo.x = roadNodes[i][2];
					roadPathNodeInfo.y = roadNodes[i][3];
					roadPathNodeInfo.sortIndex = roadNodes[i][4];
					roadPahtNodes.push(roadPathNodeInfo);
				}
				appData.roadPathNodes = roadPahtNodes;
				
				//城市节点纹理文件
				var nodeTempFileCount:int = mapFileByte.readDouble();
				len = nodeTempFileCount;
				var nodeFiles:Array = [];
				for(i = 0; i != len; i++) {
					var nodeFileObj:Object = new Object();
					var fileBytes:ByteArray = new ByteArray();
					var fileName:String = mapFileByte.readUTF();
					var fileLen:int = mapFileByte.readInt();
					mapFileByte.readBytes(fileBytes,0,fileLen);
					nodeFileObj[TEXTURE_NAME_FIELD] = fileName;
					nodeFileObj[FILE_STREAM_FIELD] = fileBytes;
					nodeFiles.push(nodeFileObj);
				}
				appData.cityNodeFiles = nodeFiles;
				
				var mapLen:Number = mapFileByte.readDouble();
				var mapFile:ByteArray = new ByteArray();
				mapFileByte.readBytes(mapFile,0,mapLen);
				appData.mapFileStream = mapFile;
				appData.cityImagesUrl = mapFileByte.readUTF();
				appData.mapFileUrl = mapFileByte.readUTF();
				
				//当前装载的城市节点图片
				nowNodeLoadCount = 0;
				loadNode();
				openFile.removeEventListener(Event.SELECT,openFunc);
				//保存文件的句柄引用
				saveFile = openFile;
			};
			
			var openFile:File = new File();
			openFile.addEventListener(Event.SELECT,openFunc);
			openFile.browseForOpen("打开地图编辑文件",[new FileFilter(".bzTmx","*.bzTmx")]);
		}
		
		/**
		 * 新建一个数据文件 
		 * @param cityNodesPath
		 * @param mapPath
		 * @return 
		 * 
		 */		
		public function createNewMapData(cityNodesPath:String,mapPath:String):Boolean {
			
			UserInterfaceManager.close(AppReg.CITY_NODE_TEMP_PANEL);
			UserInterfaceManager.close(AppReg.CITY_EDIT_PROPERTIES);
			UIMoudleManager.closeUIById(AppReg.EDITOR_CITY_NODE_PANEL);
			UIMoudleManager.closeUIById(AppReg.EDITOR_MAP_PANEL);
			
			if(!cityNodesPath) return false;
			if(!mapPath) return false;
			clearAppData();
			appData.mapFileUrl = mapPath;
			appData.cityImagesUrl = cityNodesPath;
			var nodesRoot:File = new File(cityNodesPath);
			trace("begin load cityNodeImages");
			trace("===================================");
			appData.cityNodeFiles = [];
			ansyslizerCityDirector(nodesRoot);
			trace("===================================");
			//当前装载的城市节点图片
			nowNodeLoadCount = 0;
			loadNode();
			return false;
		}
		
		/**
		 * 解析城市图片目录将节点图片转换成节点文件数据 
		 * @param rootFile
		 */		
		private function ansyslizerCityDirector(rootFile:File):void {
			var fileStream:FileStream;
			var nodeFiles:Array = rootFile.getDirectoryListing();
			var nf:File = null;
			
			for each(nf in nodeFiles) {
				if(nf.isDirectory) {
					ansyslizerCityDirector(nf);
				} else {
					var fileBytes:ByteArray = new ByteArray();
					if		(!fileStream) fileStream = new FileStream();
					else	fileStream.close();
					fileStream.open(nf,FileMode.READ);
					fileStream.readBytes(fileBytes);
					
					trace("cityNodeFile:",nf.nativePath);
					var objData:Object = new Object();
					objData[TEXTURE_NAME_FIELD] = nf.name;
					objData[FILE_STREAM_FIELD] = fileBytes;
					appData.cityNodeFiles.push(objData);
					
					//创建节点模板数据
					var cityNodeTemp:MapCityNodeTempVO = new MapCityNodeTempVO();
					cityNodeTemp.textureName = nf.name;
					appData.cityNodeTemps.push(cityNodeTemp);
				}
			}
		}
		
		/**
		 * 刷新节点模板库 
		 */		
		public function refreshCityLibary():void {
			var chrooseDir:File = new File();
			var chrooseHandler:Function = function(event:Event):void {
				appData.cityNodeBitmapdatas = [];
				appData.cityNodeFiles = [];
				appData.cityNodeTemps = [];
				appData.cityImagesUrl = chrooseDir.nativePath;
				ansyslizerCityDirector(chrooseDir);
				nowNodeLoadCount = 0;
				loadNode(true);
			}
			
			chrooseDir.addEventListener(Event.SELECT,chrooseHandler);
			chrooseDir.browseForDirectory("城市文件夹");
		}
		
		/**
		 * 更新地皮文件 
		 * @param mapFile
		 * 
		 */		
		public function updateMapFile(mapFile:File):void {
			var fileStream:FileStream = new FileStream();
			fileStream.open(mapFile,FileMode.READ);
			
			var mapFileStream:ByteArray = new ByteArray();
			fileStream.readBytes(mapFileStream);
			
			appData.mapFileStream = mapFileStream
			appData.cityImagesUrl = mapFile.nativePath;
			
			var mapLoaderFunc:Function = function(event:Event):void {
				mapLoad.contentLoaderInfo.removeEventListener(Event.COMPLETE,mapLoaderFunc);
				appData.mapBit = Bitmap(mapLoad.contentLoaderInfo.content).bitmapData;
				
				//刷新地图显示
				sendNotification(ApplicationMediator.UPDATE_MAP_FILE_AFTER_VISUAL);
			};
			
			var mapLoad:Loader = new Loader();
			mapLoad.contentLoaderInfo.addEventListener(Event.COMPLETE,mapLoaderFunc);
			mapLoad.loadBytes(appData.mapFileStream);
		}
		
		/**
		 * 加载城市节点图片 
		 */		
		private function loadNode(updateCitylibary:Boolean = false):void {
			
			var nodeLoadComplete:Function = function(event:Event):void {
				defaultCityNodeLoad.contentLoaderInfo.removeEventListener(Event.COMPLETE,nodeLoadComplete);
				//缓存位图数据
				var fileData:Object = appData.cityNodeFiles[nowNodeLoadCount];
				var objData:Object = new Object();
				objData[TEXTURE_NAME_FIELD] = fileData[TEXTURE_NAME_FIELD];
				objData[BITMAP_DATE_FIELD] = ExportTexturesUtils.checkMinpBitmapData(Bitmap(defaultCityNodeLoad.contentLoaderInfo.content).bitmapData);
				appData.cityNodeBitmapdatas.push(objData);
				
				nowNodeLoadCount++;
				loadNode(updateCitylibary);
			}
			
			if(nowNodeLoadCount < appData.cityNodeFiles.length) {
				clearNodeLoad();
				defaultCityNodeLoad = new Loader();
				defaultCityNodeLoad.contentLoaderInfo.addEventListener(Event.COMPLETE,nodeLoadComplete);
				var node_fs:ByteArray = appData.cityNodeFiles[nowNodeLoadCount][FILE_STREAM_FIELD];
				defaultCityNodeLoad.loadBytes(node_fs);
			} else {
				if(!updateCitylibary) {
					clearNodeLoad();
					installMapFile();											//装载大地图数据		
				} else {
					appDataProxy.updateTextureToGPU();							//重新上传GPU
					sendNotification(ApplicationMediator.UPDATE_CITY_LIBY);		//刷新库
				}
			}
		}
		
		/**
		 * 更新单个的城市纹理 
		 * @param textureName
		 * 
		 */		
		public function updateCityTexture(textureName:String,callBack:Function = null):void {
			var chrooseFile:File;
			var fileStream:FileStream;
			var fileBytes:ByteArray;
			var fileLoader:Loader;
			var len:int = 0;
			
			var nodeTemplate:MapCityNodeTempVO = getCityNodeTempByName(textureName);
			
			var loadComplete:Function = function(event:Event):void {
				if(fileLoader) fileLoader.removeEventListener(Event.COMPLETE,loadComplete);
				var objData:Object = null;
				
				len = appData.cityNodeFiles.length;
				while(--len > -1) {
					objData = appData.cityNodeFiles[len];
					if(objData[TEXTURE_NAME_FIELD] == textureName) {
						objData[FILE_STREAM_FIELD] = fileBytes;
					}
				}
				
				len = appData.cityNodeBitmapdatas.length;
				while(--len > -1) {
					objData = appData.cityNodeBitmapdatas[len];
					if(objData[TEXTURE_NAME_FIELD] == textureName) {
						objData[BITMAP_DATE_FIELD] = Bitmap(fileLoader.content).bitmapData;
					}
				}
				
//				len = appData.mapCityNodes.length;
//				while(--len > -1) {
//					objData = appData.mapCityNodes[len];
//					if(objData.textureName == textureName) {
//						objData.textureName = chrooseFile.name;
//					}
//				}
//				nodeTemplate.textureName = chrooseFile.name;
				
				appDataProxy.updateTextureToGPU();							//重新上传GPU
				sendNotification(ApplicationMediator.UPDATE_CITY_LIBY);		//刷新库
				
				if(callBack != null) callBack();
			}
			
			var chrooseFileHandler:Function = function(event:Event):void {
				
				fileStream = new FileStream();
				fileStream.open(chrooseFile,FileMode.READ);
				fileBytes = new ByteArray();
				fileStream.readBytes(fileBytes);
				
				fileLoader = new Loader();
				fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
				fileLoader.loadBytes(fileBytes);
			};
			
			if(nodeTemplate) {
				chrooseFile = new File();
				chrooseFile.addEventListener(Event.SELECT,chrooseFileHandler);
				chrooseFile.browseForOpen("选中一个城市图片",[new FileFilter(".png","*.png")]);
			}
		}
		
		/**
		 * 城市节点装载完成 
		 * @param event
		 */		
//		private function nodeLoadComplete(event:Event):void {
//			
//			defaultCityNodeLoad.contentLoaderInfo.removeEventListener(Event.COMPLETE,nodeLoadComplete);
//			//缓存位图数据
//			var fileData:Object = appData.cityNodeFiles[nowNodeLoadCount];
//			var objData:Object = new Object();
//			objData[TEXTURE_NAME_FIELD] = fileData[TEXTURE_NAME_FIELD];
//			objData[BITMAP_DATE_FIELD] = ExportTexturesUtils.checkMinpBitmapData(Bitmap(defaultCityNodeLoad.contentLoaderInfo.content).bitmapData);
//			appData.cityNodeBitmapdatas.push(objData);
//			
//			//创建节点模板数据
//			var cityNodeTemp:CityNodeTempVO = new CityNodeTempVO();
//			cityNodeTemp.textureName = fileData.textureName;
//			appData.cityNodeTemps.push(cityNodeTemp);
//			
//			nowNodeLoadCount++;
//			loadNode();
//		}
		
		/**
		 * 清除节点装载 
		 */		
		private function clearNodeLoad():void {
			if(defaultCityNodeLoad) {
//				defaultCityNodeLoad.contentLoaderInfo.removeEventListener(Event.COMPLETE,nodeLoadComplete);
				defaultCityNodeLoad.unloadAndStop(false);
				defaultCityNodeLoad = null;
			}
		}
		
		/**
		 * 根据texture纹理名获取一个BitmapData数据 
		 * @param textureName
		 * @return 
		 */		
		public function getCityNodeBitDataByName(textureName:String):BitmapData {
			var i:int = 0;
			var len:int = appData.cityNodeBitmapdatas.length;
			var crtBitmapData:Object;
			for(i = 0;  i!=len; i++) {
				crtBitmapData = appData.cityNodeBitmapdatas[i];
				if(crtBitmapData[TEXTURE_NAME_FIELD] == textureName) {
					return crtBitmapData[BITMAP_DATE_FIELD];
				}
			}
			return null;
		}
		
		/**
		 * 获取一个城市节点信息 
		 * @param templateId
		 * @return 
		 * 
		 */		
		public function getCityNodeInfoByTemplateId(templateId:Number):CityNodeVO {
			var i:int = appData.mapCityNodes.length;
			while(--i > -1) {
				if(appData.mapCityNodes[i].templateId == templateId && templateId != 0) {
					return appData.mapCityNodes[i];
				}
			}
			return null;
		}
		
		/**
		 * 清理数据 
		 */		
		private function clearAppData():void {
			
			appData.cityImagesUrl = "";
			appData.cityNodeBitmapdatas = [];
			appData.cityNodeFiles = [];
			appData.cityNodeTemps = [];
			
			if(appData.mapBit) {
				appData.mapBit.dispose();
				appData.mapBit = null;				
			}
			appData.mapFileStream = null;
			appData.mapFileUrl = "";
			appData.mapCityNodes = [];
			
		}
		
		/**
		 * 初始化纹理集上传给gpu
		 */		
		public function updateTextureToGPU():void {
			appData.textureManager.removeTexture("mapTexture",true);
			appData.textureManager.removeTextureAtlas("mapTexture",true);
			appData.texturepack = ExportTexturesUtils.getTextureAtls();
			
			var texture:Texture = Texture.fromBitmapData(appData.texturepack.bitData);
			var textureAtls:TextureAtlas = new TextureAtlas(texture,appData.texturepack.atls);
			appData.textureManager.addTextureAtlas("mapTexture",textureAtls);
		}
		
		/**
		 * 保存地图编辑文件 
		 */		
		public function saveMapEditorFile(saveType:int):void {
			var saveFunc:Function = function(event:Event):void {
				saveData(SAVE);
			};
			
			var cancelFunc:Function = function(event:Event):void {
				saveFile = null;
			};
			
			if(saveType == SAVE_QUICK) {
				saveData(SAVE_QUICK);
			} else {
				if(!saveFile) saveFile = new File();
				saveFile.addEventListener(Event.SELECT,saveFunc,false,0,true);
				saveFile.addEventListener(Event.CANCEL,cancelFunc,false,0,true);
				saveFile.browseForSave("保存编辑文件");
			}
		}
		
		/**
		 * 装载大地图文件数据 
		 */		
		private function installMapFile():void {
			
			if(!appData.mapFileStream) {
				//大地图的文件数据
				var mapFile:File = new File(appData.mapFileUrl);
				var mapBytes:ByteArray = new ByteArray();
				var fileStream:FileStream = new FileStream();
				
				fileStream.open(mapFile,FileMode.READ);
				fileStream.readBytes(mapBytes);
				appData.mapFileStream = mapBytes;
			}
			
			var mapLoaderFunc:Function = function(event:Event):void {
				mapLoad.contentLoaderInfo.removeEventListener(Event.COMPLETE,mapLoaderFunc);
				appData.mapBit = Bitmap(mapLoad.contentLoaderInfo.content).bitmapData;
				//新建一个数据文件完成
				sendNotification(ApplicationMediator.NEW_MAP_DATA_INIT);
			};
			
			var mapLoad:Loader = new Loader();
			mapLoad.contentLoaderInfo.addEventListener(Event.COMPLETE,mapLoaderFunc);
			mapLoad.loadBytes(appData.mapFileStream);
		}
		
		/**
		 * 保存地图数据 
		 */		
		private function saveData(saveType:int):void {
			if(!saveFile) return;
			if(saveFile.name == null || StringUtil.trim(saveFile.name).length == 0) return;
			var extensionName:String = ".bzTmx";
			if(saveFile.name.indexOf(extensionName) == -1) {
				saveFile.nativePath += extensionName;
			}
			
			var writeBytes:ByteArray = new ByteArray();
			var writeFile:FileStream = new FileStream();
			writeFile.open(saveFile,FileMode.WRITE);
			
			//写入城市节点的模板数据
			var nodeTempList:Array = getWriteNodeTemps();
			writeBytes.writeObject(nodeTempList);
			
			//写入地图上的城市节点实例数据
			var mapNodeDatas:Array = getWriteMapNodes();
			writeBytes.writeObject(mapNodeDatas);
			
			//写入所有路径的key数据
			writeBytes.writeObject(appData.roadKey);
			
			//写入路径的节点数据
			var roadNodeDatas:Array = getRoadPathNodes();
			writeBytes.writeObject(roadNodeDatas);
			
			var i:int = 0;
			var len:int = appData.cityNodeFiles.length;
			var nodeFileData:Object = null;
			
			//写入城市节点模板的文件个数
			writeBytes.writeDouble(len);
			for(i = 0; i != len; i++) {
				nodeFileData = appData.cityNodeFiles[i];
				var fileName:String = nodeFileData[TEXTURE_NAME_FIELD];
				var fileLen:int = ByteArray(nodeFileData[FILE_STREAM_FIELD]).bytesAvailable;
				writeBytes.writeUTF(nodeFileData[TEXTURE_NAME_FIELD]);						//写入文理名称
				writeBytes.writeInt(fileLen);												//写入文件byteArray的长度
				writeBytes.writeBytes(nodeFileData[FILE_STREAM_FIELD]);						//写入文件
			}
			
			writeBytes.writeDouble(appData.mapFileStream.length);							//写入大地文件数据长度
			writeBytes.writeBytes(appData.mapFileStream);									//写入大地图文件
			writeBytes.writeUTF(appData.cityImagesUrl);
			writeBytes.writeUTF(appData.mapFileUrl);
			
			writeFile.writeBytes(writeBytes);												//写入文件
			writeFile.close();
			spark.components.Alert.show("保存成功");
		}
		
		/**
		 * 获取地图上路径的节点数据 
		 * @return
		 *  
		 */		
		public function getRoadPathNodes():Array {
			var res:Array = [];
			var len:int = appData.roadPathNodes.length;
			while(--len > -1) {
				var nodeTemp:RoadPathNodeVO = appData.roadPathNodes[len]; 
				var pathNode:Array = [nodeTemp.fromCityId,
					nodeTemp.toCityId,
					nodeTemp.x,
					nodeTemp.y,
					nodeTemp.sortIndex];
				res.push(pathNode);
			}
			return res;
		}
		
		/**
		 * 获取写入的城市节点模板列表 
		 * @return 
		 */		
		public function getWriteNodeTemps():Array {
			var i:int = 0;
			var len:int = appData.cityNodeTemps.length;
			var nodeTemp:MapCityNodeTempVO;
			var nodeTempList:Array = [];
			//组织城市模板节点的数据
			for(i = 0; i != len; i++) {
				//数据格式  [0 labelX 1 labelY 2 freeX 3 freeY 4 textureName]
				nodeTemp = appData.cityNodeTemps[i];
				var nodeData:Array = [nodeTemp.labelX,
					nodeTemp.labelY,
					nodeTemp.freeX,
					nodeTemp.freeY,
					nodeTemp.textureName,
					nodeTemp.flagX,
					nodeTemp.flagY,
					nodeTemp.menuX,
					nodeTemp.menuY];
				nodeTempList.push(nodeData);
			}
			return nodeTempList;
		}
		
		/**
		 * 获取地图城市节点数据 
		 * @return 
		 */		
		public function getWriteMapNodes():Array {
			var i:int = 0
			var len:int = appData.mapCityNodes.length;
			var mapCityNode:CityNodeVO;
			var mapNodeDatas:Array = [];
			for(i = 0; i != len; i++) {
				mapCityNode = appData.mapCityNodes[i];
				//数据格式 [0 worldX 1 worldY 2 textureName 3 cityId]
				var mapCityNodeData:Array = [mapCityNode.worldX,
					mapCityNode.worldY,
					mapCityNode.textureName,
					mapCityNode.templateId,
					mapCityNode.visualFiree,
					mapCityNode.cityName,
					mapCityNode.toCityIds,
					mapCityNode.visualRaod,
					mapCityNode.reversal,
					mapCityNode.offsetX];
				mapNodeDatas.push(mapCityNodeData);
			}
			return mapNodeDatas;
		}
		
		/**
		 * @param textureName
		 * @return 
		 */		
		public function getCityNodeTempByName(textureName:String):MapCityNodeTempVO {
			var i:int = 0;
			var len:int = appData.cityNodeTemps.length;
			for(i = 0; i != len; i++) {
				if(MapCityNodeTempVO(appData.cityNodeTemps[i]).textureName == textureName) {
					return appData.cityNodeTemps[i];
				}
			}
			return null;
		}
		
		/**
		 * 删除当前城市的信息 
		 * @param cityId
		 */		
		public function removeCityInfoById(cityId:Number):void {
			var i:Number = 0;
			var len:Number = appData.mapCityNodes.length;
			var crtCityNode:CityNodeVO;
			for(i = 0; i < len;) {
				crtCityNode = appData.mapCityNodes[i];
				if(crtCityNode.templateId == cityId) {
					appData.mapCityNodes.splice(i,1);
					len = appData.mapCityNodes.length;
				} else {
					var toIndex:Number = crtCityNode.toCityIds.indexOf(cityId);
					if(toIndex > -1) {
						crtCityNode.toCityIds.splice(toIndex);
						//删除该城市的道路节点
						mapEditor.ui.roadSpace.delRoad(crtCityNode.templateId,cityId);
					}
					i++;
				}
			}
		}
		
		
		public static function get NAME():String{
			return getQualifiedClassName(AppDataProxy);
		}
		
		public function get mapEditor():MapEditorPanelConstroller {
			return UIMoudleManager.getUIMoudleByOpenId(AppReg.EDITOR_MAP_PANEL) as MapEditorPanelConstroller;
		}
	}
}