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
 * IBM-MDMWB-1.0-[d5b9adde4b249825304e898e16a5a277]
 */

package com.ibm.daimler.dsea.bobj.query;




import java.util.Vector;

import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.DWLResponse;
import com.dwl.base.db.DataAccessFactory;
import com.dwl.base.interfaces.IGenericResultSetProcessor;
import com.dwl.tcrm.coreParty.bobj.query.PartyAddressBObjQuery;
import com.dwl.tcrm.coreParty.component.TCRMPartyAddressBObj;
import com.dwl.tcrm.utilities.TCRMClassFactory;
import com.ibm.daimler.dsea.component.DSEAAdditionsExtsComponent;
import com.ibm.daimler.dsea.component.XAddressGroupBObjExt;
import com.ibm.daimler.dsea.component.XAddressGroupExtResultSetProcessor;
import com.ibm.daimler.dsea.component.XPreferenceBObj;
import com.ibm.daimler.dsea.component.XPrivacyAgreementBObj;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsPropertyKeys;
import com.ibm.daimler.dsea.entityObject.EObjXAddressGroupExtData;
import com.ibm.daimler.dsea.entityObject.XAddressGroupExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>PartyAddressBObjQuery</code> class.
 *
 * @generated
 */
public class XAddressGroupExtBObjQuery extends PartyAddressBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XAddressGroupExtBObjQuery.class);
   
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
    public XAddressGroupExtBObjQuery(String queryName, DWLControl control) {
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
    public XAddressGroupExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XAddressGroupExtInquiryData.class;
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
    if (objectToPersist instanceof XAddressGroupBObjExt) {
      String infoForLogging="persist() instanceof XAddressGroupBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(PARTY_ADDRESS_ADD)) {
        addXAddressGroup();
        addXPrivacyAgreement();
        addXPreference(); // For XPreference Add
      }else if(persistenceStrategyName.equals(PARTY_ADDRESS_UPDATE)) {
        updateXAddressGroup();
      }else if(persistenceStrategyName.equals(PARTY_ADDRESS_DELETE)) {
        deleteXAddressGroup();
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
      * Inserts xaddressgroup data by calling
      * <code>EObjXAddressGroupExtData.createEObjXAddressGroup</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXAddressGroup() throws Exception{
    logger.finest("ENTER addXAddressGroup()");
    EObjXAddressGroupExtData theEObjXAddressGroupExtData = (EObjXAddressGroupExtData) DataAccessFactory
      .getQuery(EObjXAddressGroupExtData.class, connection);
 		theEObjXAddressGroupExtData.createEObjXAddressGroupExt(
 		                                 ((TCRMPartyAddressBObj) objectToPersist).getEObjAddressGroup(),
 		                                 ((XAddressGroupBObjExt) objectToPersist).getEObjXAddressGroupExt());
    logger.finest("RETURN addXAddressGroup()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xaddressgroup data by calling
      * <code>EObjXAddressGroupExtData.updateEObjXAddressGroup</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXAddressGroup() throws Exception{
    logger.finest("ENTER updateXAddressGroup()");
    EObjXAddressGroupExtData theEObjXAddressGroupExtData = (EObjXAddressGroupExtData) DataAccessFactory
      .getQuery(EObjXAddressGroupExtData.class, connection);
 		theEObjXAddressGroupExtData.updateEObjXAddressGroupExt(
 		                                 ((TCRMPartyAddressBObj) objectToPersist).getEObjAddressGroup(),
 		                                 ((XAddressGroupBObjExt) objectToPersist).getEObjXAddressGroupExt());
    logger.finest("RETURN updateXAddressGroup()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xaddressgroup data by calling
      * <code>EObjXAddressGroupExtData.deleteEObjXAddressGroup</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXAddressGroup() throws Exception{
    logger.finest("ENTER deleteXAddressGroup()");
    Long id = ((XAddressGroupBObjExt) objectToPersist).getEObjAddressGroup().getLocationGroupIdPK();
    EObjXAddressGroupExtData theEObjXAddressGroupExtData = (EObjXAddressGroupExtData) DataAccessFactory
      .getQuery(EObjXAddressGroupExtData.class, connection);
    theEObjXAddressGroupExtData.deleteEObjXAddressGroupExt(id);
    logger.finest("RETURN deleteXAddressGroup()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XAddressGroupExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XAddressGroupExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XAddressGroupExtResultSetProcessor();
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

	protected void addXPreference() throws Exception {
		logger.finest("ENTER addXPreference()");

		DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
				.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
		String partyAddressId = ((XAddressGroupBObjExt) objectToPersist)
				.getPartyAddressIdPK();
		XPreferenceBObj xPreferenceBObj = ((XAddressGroupBObjExt) objectToPersist)
				.getXPreferenceBObj();

		if (xPreferenceBObj != null) {

			xPreferenceBObj.setControl(control);
			xPreferenceBObj.setLocationGroupId(partyAddressId);
			dSEAAdditionsExtsComponent.addXPreference(xPreferenceBObj);

		}

	}

	protected void updateXPreference() throws Exception {
		logger.finest("ENTER updateXPreference()");
		DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
				.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
		String partyAddressId = ((XAddressGroupBObjExt) objectToPersist)
				.getPartyAddressIdPK();
		XPreferenceBObj xPreferenceBObj = ((XAddressGroupBObjExt) objectToPersist)
				.getXPreferenceBObj();
		DWLResponse response = null;
		if (partyAddressId != null) {
			response = dSEAAdditionsExtsComponent
					.getXPreferenceByLocationGroupId(partyAddressId, control);
			if (response != null) {
				Vector<XPreferenceBObj> xpref = (Vector<XPreferenceBObj>) response.getData();
				xPreferenceBObj.setLocationGroupId(xpref.firstElement().getLocationGroupId());
				xPreferenceBObj.setPreferencepkId(xpref.firstElement().getPreferencepkId());
				xPreferenceBObj.setXPreferenceLastUpdateDate(xpref.firstElement().getXPreferenceLastUpdateDate());
				dSEAAdditionsExtsComponent.updateXPreference(xPreferenceBObj);
			}
		}
	}
	
	protected void addXPrivacyAgreement() throws Exception {
		logger.finest("ENTER addXPrivacyAgreement()");

		DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
				.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
		String partyAddressId = ((XAddressGroupBObjExt) objectToPersist)
				.getPartyAddressIdPK();
		XPrivacyAgreementBObj xPrivacyAgreementBObj = ((XAddressGroupBObjExt) objectToPersist)
				.getXPrivacyAgreementBObj();

		if (xPrivacyAgreementBObj != null) {

			xPrivacyAgreementBObj.setControl(control);
			xPrivacyAgreementBObj.setLocationGroupId(partyAddressId);
			dSEAAdditionsExtsComponent.addXPrivacyAgreement(xPrivacyAgreementBObj);

		}

	}

	protected void updateXPrivacyAgreement() throws Exception {
		logger.finest("ENTER updateXPrivacyAgreement()");
		DSEAAdditionsExtsComponent dSEAAdditionsExtsComponent = (DSEAAdditionsExtsComponent) TCRMClassFactory
				.getTCRMComponent(DSEAAdditionsExtsPropertyKeys.DSEAADDITIONS_EXTS_COMPONENT);
		String partyAddressId = ((XAddressGroupBObjExt) objectToPersist)
				.getPartyAddressIdPK();
		DWLResponse response = null;
		if (partyAddressId != null) {
			response = dSEAAdditionsExtsComponent
					.getXPrivAgreementByLocationGroupId(partyAddressId, control);
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
