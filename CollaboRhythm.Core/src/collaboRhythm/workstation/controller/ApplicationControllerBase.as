package collaboRhythm.workstation.controller
{
	import castle.flexbridge.kernel.DefaultKernel;
	import castle.flexbridge.kernel.IKernel;
	
	import collaboRhythm.workstation.model.Settings;
	import collaboRhythm.workstation.model.User;
	import collaboRhythm.workstation.model.services.DefaultCurrentDateSource;
	import collaboRhythm.workstation.model.services.DemoCurrentDateSource;
	import collaboRhythm.workstation.model.services.ICurrentDateSource;
	import collaboRhythm.workstation.model.services.WorkstationKernel;
	import collaboRhythm.workstation.model.settings.ComponentLayout;
	import collaboRhythm.workstation.model.settings.WindowSettings;
	import collaboRhythm.workstation.model.settings.WindowSettingsDataStore;
	import collaboRhythm.workstation.model.settings.WindowState;
	import collaboRhythm.workstation.view.CollaborationRoomView;
	import collaboRhythm.workstation.view.RemoteUsersListView;
	import collaboRhythm.workstation.view.WorkstationCommandBarView;
	import collaboRhythm.workstation.view.spaces.CenterSpace;
	import collaboRhythm.workstation.view.spaces.LeftSpace;
	import collaboRhythm.workstation.view.spaces.RightSpace;
	import collaboRhythm.workstation.view.spaces.SingleWindowSpaceCombination;
	import collaboRhythm.workstation.view.spaces.TopSpace;
	
	import com.daveoncode.logging.LogFileTarget;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.DividedBox;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	import spark.components.Window;

	public class ApplicationControllerBase
	{
		protected var _kernel:IKernel;
		protected var _settings:Settings;
		protected var _collaborationMediator:CollaborationMediatorBase;
		protected var logger:ILogger;
		
		public function get settings():Settings
		{
			return _settings;
		}
		
		public function get collaborationRoomView():CollaborationRoomView
		{
			throw new Error("virtual function must be overriden in subclass");
		}
		
		public function get remoteUsersView():RemoteUsersListView
		{
			throw new Error("virtual function must be overriden in subclass");
		}
		
		public function get widgetsContainer():IVisualElementContainer
		{
			throw new Error("virtual function must be overriden in subclass");
		}
		
		public function get scheduleWidgetContainer():IVisualElementContainer
		{
			throw new Error("virtual function must be overriden in subclass");
		}
		
		public function get fullContainer():IVisualElementContainer
		{
			throw new Error("virtual function must be overriden in subclass");
		}
		
		public function ApplicationControllerBase()
		{
		}

		protected function initLogging():void
		{
			// The log file will be placed under applicationStorageDirectory folder
			var path:String = File.applicationStorageDirectory.resolvePath("collaboRhythm.log").nativePath;
			
			var targetFile:File = new File(path);
			
			/* Create a target. */
			//			var logTarget:TraceTarget = new TraceTarget();
			
			// get LogFileTarget's instance (LogFileTarget is a singleton)
			var logTarget:LogFileTarget = LogFileTarget.getInstance();
			
			logTarget.file = targetFile;
			//			logTarget.file = new File("C:\\Users\\sgilroy\\AppData\\Roaming\\collaboRhythm.workstation\\Local Store\\collaboRhythm.log");
			
			// optional (default to "MM/DD/YY")
			//			target.dateFormat = "DD/MM/YY";
			
			// optional  (default to 1024)
			//			target.sizeLimit = 2048;
			
			// Trace all (default Flex's framework features)
			//			target.filters = ["*"];
			//			target.level = LogEventLevel.ALL;
			
			/* Log only messages for the classes in the collaboRhythm.workstation.* packages. */
//			logTarget.filters=["collaboRhythm.workstation.*"];
			
			/* Log all log levels. */
			logTarget.level = LogEventLevel.ALL;
			
			/* Add date, time, category, and log level to the output. */
			//			logTarget.includeDate = true;
			//			logTarget.includeTime = true;
			//			logTarget.includeCategory = true;
			//			logTarget.includeLevel = true;
			
			/* Begin logging. */
			Log.addTarget(logTarget);
			
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}
		
		protected function testLogging():void
		{
			logger.info("Testing logger");
		}
		
		protected function set targetDate(value:Date):void
		{
			_settings.targetDate = value;
			var dateSource:DemoCurrentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as DemoCurrentDateSource;
			if (dateSource != null)
			{
				dateSource.targetDate = value;
				changeDemoDate();
			}
		}
		
		protected function changeDemoDate():void
		{
			_collaborationMediator.changeDemoDate();
		}
		
		protected function initializeComponents():void
		{
			_kernel = WorkstationKernel.instance;
			
			//			_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, new DefaultCurrentDateSource());
			var dateSource:DemoCurrentDateSource = new DemoCurrentDateSource();
			dateSource.targetDate = _settings.targetDate;
			_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, dateSource);
		}
		
	}
}