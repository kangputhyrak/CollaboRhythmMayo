/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model
{
	import collaboRhythm.shared.model.DateUtil;
    import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	[Bindable]
	public class Problem extends DocumentMetadata
	{
		private var _name:String;
		private var _commonName:String;
		private var _dateOnset:Date;
		private var _dateResolution:Date;
		private var _currentDateSource:ICurrentDateSource;
		
		public function Problem()
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function initFromReportXML(problemReportXml:XML):void
        {
            parseDocumentMetadata(problemReportXml.Meta.Document[0], this);
			var problemXml:XML = problemReportXml.Item.Equipment[0];
            //TODO: Currently there are not any problems in the record, so this code has not been validated
            _name = problemXml.name;
			_commonName = problemXml.comments;
			_dateOnset =  DateUtil.parseW3CDTF(problemXml.dateOnset.toString());
			_dateResolution =  DateUtil.parseW3CDTF(problemXml.dateResolution.toString());
        }

		public function get commonNameLabel():String
		{
			if (_commonName != null && _commonName.length > 0)
				return "(" + _commonName + ")";
			
			return null;
		}
		
		public function get commonName():String
		{
			return _commonName;
		}

		public function set commonName(value:String):void
		{
			_commonName = value;
		}

		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get isInactive():Boolean
		{
			if (_dateResolution != null)
			{
				return _dateResolution < _currentDateSource.now();
			}
			return false;
		}
	}
}