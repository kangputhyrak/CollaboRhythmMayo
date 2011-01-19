package collaboRhythm.workstation.apps.problems.model
{
	import collaboRhythm.workstation.model.HealthRecordServiceBase;
	import collaboRhythm.workstation.model.User;
	import collaboRhythm.workstation.model.UsersModel;
	
	import flash.net.URLVariables;
	
	import org.indivo.client.IndivoClientEvent;
	
	public class ProblemsHealthRecordService extends HealthRecordServiceBase
	{
		public function ProblemsHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
		}

		public function loadAllProblems(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadProblems(user);
			}
			loadProblems(remoteUserModel.localUser);
		}

		public function loadProblems(user:User):void
		{
			if (user.appData[ProblemsModel.PROBLEMS_KEY] == null)
			{
				user.appData[ProblemsModel.PROBLEMS_KEY] = new ProblemsModel();
			}
			
			var params:URLVariables = new URLVariables();
			params["order_by"] = "-date_onset";
			
			// now the user already had an empty ProblemsModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty ProblemsModel so that views can bind to the instance before the data is finished loading
			//			user.problemsModel = new ProblemsModel();
			if (user.recordId != null && accessKey != null && accessSecret != null)
				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "problems", accessKey, accessSecret, user);
		}

		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML):void
		{
			var user:User;
			if (responseXml.name() == "Reports")
			{
				user = event.userData as User;
				
				var problemsModel:ProblemsModel = user.getAppData(ProblemsModel.PROBLEMS_KEY, ProblemsModel) as ProblemsModel;
				if (problemsModel)
					problemsModel.rawData = responseXml;
			}
			else
			{
				throw new Error("Unhandled response data: " + responseXml.name() + " " + responseXml);
			}
		}
	}
}