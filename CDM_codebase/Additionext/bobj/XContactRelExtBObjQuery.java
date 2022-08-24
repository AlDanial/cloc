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
 * IBM-MDMWB-1.0-[759005c024adc75d17de4ed4175ed1f2]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.coreParty.bobj.query.PartyRelationshipBObjQuery;

import com.dwl.tcrm.coreParty.component.TCRMPartyRelationshipBObj;

import com.ibm.daimler.dsea.component.XContactRelBObjExt;
import com.ibm.daimler.dsea.component.XContactRelExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXContactRelExtData;
import com.ibm.daimler.dsea.entityObject.XContactRelExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>PartyRelationshipBObjQuery</code> class.
 *
 * @generated
 */
public class XContactRelExtBObjQuery extends PartyRelationshipBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XContactRelExtBObjQuery.class);
   
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
    public XContactRelExtBObjQuery(String queryName, DWLControl control) {
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
    public XContactRelExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XContactRelExtInquiryData.class;
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
    if (objectToPersist instanceof XContactRelBObjExt) {
      String infoForLogging="persist() instanceof XContactRelBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(PARTY_RELATIONSHIP_ADD)) {
        addXContactRel();
      }else if(persistenceStrategyName.equals(PARTY_RELATIONSHIP_UPDATE)) {
        updateXContactRel();
      }else if(persistenceStrategyName.equals(PARTY_RELATIONSHIP_DELETE)) {
        deleteXContactRel();
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
      * Inserts xcontactrel data by calling
      * <code>EObjXContactRelExtData.createEObjXContactRel</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXContactRel() throws Exception{
    logger.finest("ENTER addXContactRel()");
    EObjXContactRelExtData theEObjXContactRelExtData = (EObjXContactRelExtData) DataAccessFactory
      .getQuery(EObjXContactRelExtData.class, connection);
 		theEObjXContactRelExtData.createEObjXContactRelExt(
 		                                 ((TCRMPartyRelationshipBObj) objectToPersist).getEObjContactRel(),
 		                                 ((XContactRelBObjExt) objectToPersist).getEObjXContactRelExt());
    logger.finest("RETURN addXContactRel()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcontactrel data by calling
      * <code>EObjXContactRelExtData.updateEObjXContactRel</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXContactRel() throws Exception{
    logger.finest("ENTER updateXContactRel()");
    EObjXContactRelExtData theEObjXContactRelExtData = (EObjXContactRelExtData) DataAccessFactory
      .getQuery(EObjXContactRelExtData.class, connection);
 		theEObjXContactRelExtData.updateEObjXContactRelExt(
 		                                 ((TCRMPartyRelationshipBObj) objectToPersist).getEObjContactRel(),
 		                                 ((XContactRelBObjExt) objectToPersist).getEObjXContactRelExt());
    logger.finest("RETURN updateXContactRel()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xcontactrel data by calling
      * <code>EObjXContactRelExtData.deleteEObjXContactRel</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXContactRel() throws Exception{
    logger.finest("ENTER deleteXContactRel()");
    Long id = ((XContactRelBObjExt) objectToPersist).getEObjContactRel().getContRelIdPK();
    EObjXContactRelExtData theEObjXContactRelExtData = (EObjXContactRelExtData) DataAccessFactory
      .getQuery(EObjXContactRelExtData.class, connection);
    theEObjXContactRelExtData.deleteEObjXContactRelExt(id);
    logger.finest("RETURN deleteXContactRel()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XContactRelExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XContactRelExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XContactRelExtResultSetProcessor();
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


