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
 * IBM-MDMWB-1.0-[67867df6ea6b166e2ceecc621c570d0f]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.coreParty.bobj.query.OrganizationBObjQuery;

import com.dwl.tcrm.coreParty.component.TCRMOrganizationBObj;

import com.ibm.daimler.dsea.component.XOrgBObjExt;
import com.ibm.daimler.dsea.component.XOrgExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXOrgExtData;
import com.ibm.daimler.dsea.entityObject.XOrgExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>OrganizationBObjQuery</code> class.
 *
 * @generated
 */
public class XOrgExtBObjQuery extends OrganizationBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XOrgExtBObjQuery.class);
   
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
    public XOrgExtBObjQuery(String queryName, DWLControl control) {
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
    public XOrgExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XOrgExtInquiryData.class;
    }
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
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
    if (objectToPersist instanceof XOrgBObjExt) {
      String infoForLogging="persist() instanceof XOrgBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(ORGANIZATION_ADD)) {
        addXOrg();
      }else if(persistenceStrategyName.equals(ORGANIZATION_UPDATE)) {
        updateXOrg();
      }else if(persistenceStrategyName.equals(ORGANIZATION_DELETE)) {
        deleteXOrg();
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
      * Inserts xorg data by calling <code>EObjXOrgExtData.createEObjXOrg</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXOrg() throws Exception{
    logger.finest("ENTER addXOrg()");
    EObjXOrgExtData theEObjXOrgExtData = (EObjXOrgExtData) DataAccessFactory
      .getQuery(EObjXOrgExtData.class, connection);
 		theEObjXOrgExtData.createEObjXOrgExt(
 		                                 ((TCRMOrganizationBObj) objectToPersist).getEObjOrganization(),
 		                                 ((XOrgBObjExt) objectToPersist).getEObjXOrgExt());
    logger.finest("RETURN addXOrg()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xorg data by calling <code>EObjXOrgExtData.updateEObjXOrg</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXOrg() throws Exception{
    logger.finest("ENTER updateXOrg()");
    EObjXOrgExtData theEObjXOrgExtData = (EObjXOrgExtData) DataAccessFactory
      .getQuery(EObjXOrgExtData.class, connection);
 		theEObjXOrgExtData.updateEObjXOrgExt(
 		                                 ((TCRMOrganizationBObj) objectToPersist).getEObjOrganization(),
 		                                 ((XOrgBObjExt) objectToPersist).getEObjXOrgExt());
    logger.finest("RETURN updateXOrg()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xorg data by calling <code>EObjXOrgExtData.deleteEObjXOrg</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXOrg() throws Exception{
    logger.finest("ENTER deleteXOrg()");
    Long id = ((XOrgBObjExt) objectToPersist).getEObjOrganization().getContIdPK();
    EObjXOrgExtData theEObjXOrgExtData = (EObjXOrgExtData) DataAccessFactory
      .getQuery(EObjXOrgExtData.class, connection);
    theEObjXOrgExtData.deleteEObjXOrgExt(id);
    logger.finest("RETURN deleteXOrg()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XOrgExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XOrgExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XOrgExtResultSetProcessor();
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
}


