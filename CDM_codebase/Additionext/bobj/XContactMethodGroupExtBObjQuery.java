/*
 * The following source code ("Code") may only be used in accordance with the terms
 * and conditions of the license agreement you have with IBM Corporation. The Code 
 * is provided to you on an "AS IS" basis, without warranty of any kind.  
 * SUBJECT TO ANY STATUTORY WARRANTIES WHICH CAN NOT BE EXCLUDED, IBM MAKES NO 
 * WARRANTIES OR CONDITIONS EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
 * TO, THE IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE, AND NON-INFRINGEMENT, REGARDING THE CODE. IN NO EVENT WILL 
 * IBM BE LIABLE TO YOU OR ANY PARTY FOR ANY DIRECT, INDIRECT, SPECIAL OR OTHER 
 * CONSEQUENTIAL DAMAGES FOR ANY USE OF THE CODE, INCLUDING, WITHOUT LIMITATION, 
 * LOSS OF, OR DAMAGE TO, DATA, OR LOST PROFITS, BUSINESS, REVENUE, GOODWILL, OR 
 * ANTICIPATED SAVINGS, EVEN IF IBM HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
 * DAMAGES. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR LIMITATION OF 
 * INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION OR EXCLUSION MAY 
 * NOT APPLY TO YOU.
 */

/*
 * IBM-MDMWB-1.0-[9e6cc8e98ab569498e30f05a6fa37225]
 */

package com.ibm.daimler.dsea.bobj.query;




import java.util.Vector;

import com.dwl.base.DWLCommon;
import com.dwl.base.DWLControl;
import com.dwl.base.DWLResponse;
import com.dwl.base.db.DataAccessFactory;
import com.dwl.base.interfaces.IGenericResultSetProcessor;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.tcrm.coreParty.bobj.query.PartyContactMethodBObjQuery;
import com.dwl.tcrm.coreParty.component.TCRMPartyContactMethodBObj;
import com.dwl.tcrm.utilities.TCRMClassFactory;
import com.ibm.daimler.dsea.component.DSEAAdditionsExtsComponent;
import com.ibm.daimler.dsea.component.XAddressGroupBObjExt;
import com.ibm.daimler.dsea.component.XContactMethodGroupBObjExt;
import com.ibm.daimler.dsea.component.XContactMethodGroupExtResultSetProcessor;
import com.ibm.daimler.dsea.component.XPreferenceBObj;
import com.ibm.daimler.dsea.component.XPrivacyAgreementBObj;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsPropertyKeys;
import com.ibm.daimler.dsea.entityObject.EObjXContactMethodGroupExtData;
import com.ibm.daimler.dsea.entityObject.XContactMethodGroupExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>PartyContactMethodBObjQuery</code> class.
 *
 * @generated
 */
public class XContactMethodGroupExtBObjQuery extends PartyContactMethodBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XContactMethodGroupExtBObjQuery.class);
   
   /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @param queryName
     *     The name of the query.
     * @param control
     *     The control object.
     *
     * @generated
     */
    public XContactMethodGroupExtBObjQuery(String queryName, DWLControl control) {
        super(queryName, control);
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @param persistenceStrategyName
     * The persistence strategy name.  This parameter indicates the type of
     * database action to be taken such as addition, update or deletion of
     * records.
     * @param objectToPersist
     * The business object to be persisted.
     *
     * @generated
     */
    public XContactMethodGroupExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
        super(persistenceStrategyName, objectToPersist);
    }


    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
     @SuppressWarnings("rawtypes")
    protected Class provideQueryInterfaceClass()  throws BObjQueryException  {
        return XContactMethodGroupExtInquiryData.class;
    }
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated NOT
     */
	protected void persist() throws Exception{
    logger.finest("ENTER persist()");
    if (logger.isFinestEnabled()) {
    		String infoForLogging="Persistence strategy is " + persistenceStrategyName;
      logger.finest("persist() " + infoForLogging);
    }
    if (logger.isFinestEnabled()) {
      String infoForLogging=" Extension with fields added to DB table";
      logger.finest("persist() " + infoForLogging);
    }
    if (objectToPersist instanceof XContactMethodGroupBObjExt) {
      String infoForLogging="persist() instanceof XContactMethodGroupBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(PARTY_CONTACT_METHOD_ADD)) {
        addXContactMethodGroup();
        addXPreference();
		addXPrivacyAgreement();
      }else if(persistenceStrategyName.equals(PARTY_CONTACT_METHOD_UPDATE)) {
        updateXContactMethodGroup();
      }else if(persistenceStrategyName.equals(PARTY_CONTACT_METHOD_DELETE)) {
        deleteXContactMethodGroup();
      }else {
        super.persist();
      }
    } else {
      if (logger.isFinestEnabled()) {
        String infoForLogging="Call super.persist()";
      logger.finest("persist() " + infoForLogging);
      }
      super.persist();
    }		
    
    logger.finest("RETURN persist()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xcontactmethodgroup data by calling
      * <code>EObjXContactMethodGroupExtData.createEObjXContactMethodGroup</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXContactMethodGroup() throws Exception{
    logger.finest("ENTER addXContactMethodGroup()");
    EObjXContactMethodGroupExtData theEObjXContactMethodGroupExtData = (EObjXContactMethodGroupExtData) DataAccessFactory
      .getQuery(EObjXContactMethodGroupExtData.class, connection);
 		theEObjXContactMethodGroupExtData.createEObjXContactMethodGroupExt(
 		                                 ((TCRMPartyContactMethodBObj) objectToPersist).getEObjContactMethodGroup(),
 		                                 ((XContactMethodGroupBObjExt) objectToPersist).getEObjXContactMethodGroupExt());
    logger.finest("RETURN addXContactMethodGroup()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcontactmethodgroup data by calling
      * <code>EObjXContactMethodGroupExtData.updateEObjXContactMethodGroup</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXContactMethodGroup() throws Exception{
    logger.finest("ENTER updateXContactMethodGroup()");
    EObjXContactMethodGroupExtData theEObjXContactMethodGroupExtData = (EObjXContactMethodGroupExtData) DataAccessFactory
      .getQuery(EObjXContactMethodGroupExtData.class, connection);
 		theEObjXContactMethodGroupExtData.updateEObjXContactMethodGroupExt(
 		                                 ((TCRMPartyContactMethodBObj) objectToPersist).getEObjContactMethodGroup(),
 		                                 ((XContactMethodGroupBObjExt) objectToPersist).getEObjXContactMethodGroupExt());
    logger.finest("RETURN updateXContactMethodGroup()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xcontactmethodgroup data by calling
      * <code>EObjXContactMethodGroupExtData.deleteEObjXContactMethodGroup</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXContactMethodGroup() throws Exception{
    logger.finest("ENTER deleteXContactMethodGroup()");
    Long id = ((XContactMethodGroupBObjExt) objectToPersist).getEObjContactMethodGroup().getLocationGroupIdPK();
    EObjXContactMethodGroupExtData theEObjXContactMethodGroupExtData = (EObjXContactMethodGroupExtData) DataAccessFactory
      .getQuery(EObjXContactMethodGroupExtData.class, connection);
    theEObjXContactMethodGroupExtData.deleteEObjXContactMethodGroupExt(id);
    logger.finest("RETURN deleteXContactMethodGroup()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XContactMethodGroupExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XContactMethodGroupExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XContactMethodGroupExtResultSetProcessor();
    }    


    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    protected String getSQLStatement() throws BObjQueryException {
        String sql = super.getSQLStatement();
        if (sql != null) {
            return sql;
        }
        return getSQLStatement(super.provideQueryInterfaceClass());
    }
    
/* Start for DSEA */
    
    protected void addXPreference() throws Exception{
		logger.finest("ENTER addXPreference()");

		DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
				.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
		String partyContactMethodId = ((XContactMethodGroupBObjExt)objectToPersist).getPartyContactMethodIdPK();
		XPreferenceBObj xPreferenceBObj = ((XContactMethodGroupBObjExt) objectToPersist).getXPreferenceBObj();
		
		if(xPreferenceBObj != null){
		 
		xPreferenceBObj.setControl(control);
		xPreferenceBObj.setLocationGroupId(partyContactMethodId);
		dSEAAdditionsExtsComponent.addXPreference(xPreferenceBObj);
		
		}
		
		}
		
		protected void updateXPreference() throws Exception{
			logger.finest("ENTER updateXPreference()");

			DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
					.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
			String partyContactMethodId = ((XContactMethodGroupBObjExt)objectToPersist).getPartyContactMethodIdPK();
			DWLResponse response = null;
			if (partyContactMethodId != null) {
				response = dSEAAdditionsExtsComponent
						.getXPreferenceByLocationGroupId(partyContactMethodId, control);
				if (response != null) {
					XPreferenceBObj xpref = (XPreferenceBObj) response.getData();
					dSEAAdditionsExtsComponent.updateXPreference(xpref);
				}
			}
			
		}
		
		protected void addXPrivacyAgreement() throws Exception {
			logger.finest("ENTER addXPrivacyAgreement()");

			DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
					.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
			String partyContactMethodId = ((XContactMethodGroupBObjExt)objectToPersist).getPartyContactMethodIdPK();
			XPrivacyAgreementBObj xPrivacyAgreementBObj = ((XContactMethodGroupBObjExt) objectToPersist)
					.getXPrivacyAgreementBObj();

			if (xPrivacyAgreementBObj != null) {

				xPrivacyAgreementBObj.setControl(control);
				xPrivacyAgreementBObj.setLocationGroupId(partyContactMethodId);
				dSEAAdditionsExtsComponent.addXPrivacyAgreement(xPrivacyAgreementBObj);

			}

		}
		
		protected void updateXPrivacyAgreement() throws Exception {
			logger.finest("ENTER updateXPrivacyAgreement()");
			DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
					.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
			String partyContactMethodId = ((XContactMethodGroupBObjExt)objectToPersist).getPartyContactMethodIdPK();
			DWLResponse response = null;
			if (partyContactMethodId != null) {
				response = dSEAAdditionsExtsComponent
						.getXPrivAgreementByLocationGroupId(partyContactMethodId, control);
				if (response != null) {
					Object o= response.getData();
					Vector<XPrivacyAgreementBObj> xprivAgreementVect = (Vector<XPrivacyAgreementBObj>)response.getData();
					for(XPrivacyAgreementBObj xprivAgreement : xprivAgreementVect){
						dSEAAdditionsExtsComponent.updateXPrivacyAgreement(xprivAgreement);
					}
					
				}
			}
		}
    /* End for DSEA */
}


