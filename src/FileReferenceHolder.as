package
{
	import flash.net.FileReference;
	
	public class FileReferenceHolder
	{
		private static var idcounter:Number = 0;
		private var fileReference:FileReference;
		private var id:String;
		
		public function FileReferenceHolder(file:FileReference)
		{
			this.fileReference = file;
			id = "uploadfile_" + idcounter++;
		}
		
		public function getInfo():Object
		{
			return {
				name: fileReference.name,
				size: fileReference.size,
				id: id
			};
		}
		
		public function getFileReference():FileReference
		{
			return fileReference;
		}
		
		public function getId():String
		{
			return id;
		}

	}
	
}