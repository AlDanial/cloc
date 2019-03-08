// https://github.com/financialforcedev/apex-mdapi.git
//      apex-mdapi/apex-mdapi/src/classes/RemoteSiteHelperTest.cls
@IsTest
private class RemoteSiteHelperTest 
{
	@IsTest
	private static void testCheckMetadataAPIConnection()
	{			
    	// Metadata API web Service mock implementation for tests
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		
		RemoteSiteHelperController controller = new RemoteSiteHelperController();
		System.assertEquals(true, controller.MetadataConnectionWarning);		
		controller.MetadataResponse = '';
		controller.displayMetadataResponse();
		System.assertEquals(false, controller.MetadataConnectionWarning);
		controller.MetadataResponse = 'Some Error Creating Remote Site Setting';
		controller.displayMetadataResponse();
		System.assertEquals(true, controller.MetadataConnectionWarning);
	}
	
    /**
     * Metadata API web service mock class for tests above
     **/
	private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			throw new TestException();
		}
	}
	
	public class TestException extends Exception { }
}
