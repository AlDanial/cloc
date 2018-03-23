* https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.asma100/appndxe.htm
**************************************************************          
*   Licensed Materials - Property of IBM                     *          
*                                                            *          
*   5696-234   5647-A01                                      *          
*                                                            *          
*   (C) Copyright IBM Corp. 1992, 2000. All Rights Reserved. *          
*                                                            *          
*   US Government Users Restricted Rights - Use,             *          
*   duplication or disclosure restricted by GSA ADP          *          
*   Schedule Contract with IBM Corp.                         *          
*                                                            *          
**************************************************************          
*********************************************************************   
* DISCLAIMER OF WARRANTIES                                          *   
*  The following enclosed code is sample code created by IBM        *   
*  Corporation. This sample code is licensed under the terms of     *   
*  the High Level Assembler license, but is not part of any         *   
*  standard IBM product.  It is provided to you solely for the      *   
*  purpose of demonstrating the usage of some of the features of    *   
*  High Level Assembler.  The code is not supported by IBM and      *   
*  is provided on an "AS IS" basis, without warranty of any kind.   *   
*  IBM shall not be liable for any damages arising out of your      *   
*  use of the sample code, even if IBM has been advised of the      *   
*  possibility of such damages.                                     *   
*********************************************************************   
a        csect                                                          
         using *,8                                                      
         sr    15,15      Set return code to zero                       
         br    14          and return.                                  
**********************************************************************  
*              PUSH  and POP  statements                             *  
* Push down the PRINT statement, replace it, retrieve original       *  
**********************************************************************  
         push  print     Save Default setting '  PRINT ON,NODATA,GEN'   
         print nogen,data                                               
         wto   mf=(E,(1))                    Expansion not shown        
