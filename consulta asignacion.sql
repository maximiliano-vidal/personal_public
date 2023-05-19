        Select
                result.HIERARCHY,
                result.id_action,
                result.action,
                result.id_region,
                (select name from my_reports_region where id_region = result.id_region) as region_name,
                result.id_user,
                result.isid,
                result.LAST_NAME,
                result.FIRST_NAME,
                result.EMAIL,
                result.active,
                COALESCE(result.REGION_NAME, 'Empty') employee_REGION_NAME,
                COALESCE(result.POSITION_DESCRIPTION, 'Empty') POSITION_DESCRIPTION,
                result.id_area,
                result.id_group,
                result.id_element,
                result.id_role,
                result.DIVISION_NAME,
                COALESCE(result.name, 'Empty') name,
                COALESCE(result.ASSOCIATION_SOURCE,'Empty') ASSOCIATION_SOURCE,
                COALESCE(result.ASSOCIATION_ROLE, 'Empty') ASSOCIATION_ROLE,
                COALESCE(result.security_group, 'Empty') security_group,
                COALESCE(result.segment, 'Empty') segment,
                result.remedy,
                result.service_now,
                result.last_access,
				result.ISID_APPROVER,
				result.PERMISSION_TYPE
        from
        (
          SELECT
                'ELEMENT' HIERARCHY, msa.id_action, ma.DESCRIPTION action, msa.id_context id_region,  msr.id_user,
                u.login isid,  u.LAST_NAME, u.FIRST_NAME, u.EMAIL, u.active, NVL(employee.REGION_NAME, '') AS REGION_NAME,
                NVL(employee.POSITION_DESCRIPTION,'') AS POSITION_DESCRIPTION, mr.id_area, mr.id_group, mr.id_element, msr.id_role, u.DIVISION_NAME, rol.name,
                rol.ASSOCIATION_SOURCE,	rol.ASSOCIATION_ROLE, security.ASSOCIATION_ROLE security_group,
                (SELECT als.description from USER_SEGMENT us		         
                    inner JOIN ACCESS_LINK_SEGMENT als
                    ON als.ID_SEGMENT = us.ID_SEGMENT AND als.ID_PRODUCT = tmp.id_product
                    WHERE   us.ID_USER = u.ID_USER) AS segment, 
                decode(rem.ID_PRODUCT, NULL, 'N', 'Y') remedy,
                decode(svcnow.ID_PRODUCT, NULL, 'N', DECODE(svcnow.ACTION_REQUESTED, 'Remove', 'N' ,'Y')) service_now,
                (SELECT max(logaux.date_action) as last_access  
                                        FROM si_log logaux 
                                       WHERE logaux.user_name = u.username
                                         AND logaux.operation = 'reportAccess'
                                         AND logaux.object_action = tmp.id_product) AS last_access,
				decode(orig.ISID_APPROVER, NULL, '', assigner.LAST_NAME || ', ' || assigner.FIRST_NAME || ' (' || orig.ISID_APPROVER || ')') AS ISID_APPROVER,
				orig.PERMISSION_TYPE										 
            FROM
                myrpts_subject_attribute msa
                INNER JOIN myrpts_action ma ON msa.id_action = ma.id_action
                INNER JOIN myrpts_subject_relation msr ON msa.id_subject = msr.id_subject
                INNER JOIN usr u ON msr.id_user = u.id_user
                INNER JOIN Temp_ tmp ON u.id_user = tmp.id_user
                INNER JOIN myrpts_resources mr ON msa.id_resource = mr.id_resource
                INNER JOIN MYRPTS_ELEMENT_RELATION e ON e.ID_ELEMENT = mr.ID_ELEMENT
				LEFT JOIN MYRPTS_PERMISSION_ORIG orig ON (orig.ID_RESOURCE = mr.ID_RESOURCE AND orig.ID_SUBJECT = msr.ID_SUBJECT)
                LEFT JOIN usr assigner ON (assigner.id_user = orig.ID_USER_APPROVER)
                LEFT JOIN MYRPTS_COMPANY_EMPLOYEE employee ON employee.ID_USER = u.ID_USER
                LEFT JOIN (SELECT  ur.ID_USER AS id_user, decode(rl.IS_VISIBLE, 'Y', rl.name, '' ) AS name,
                            ur.EXTERNAL_SOURCE_NAME AS ASSOCIATION_SOURCE,	ur.EXTERNAL_ROLE_NAME AS ASSOCIATION_ROLE,
                            RES.ID_AREA,  SUB_ATT.ID_CONTEXT, RES.ID_GROUP , RES.ID_ELEMENT
                            FROM ROLE RL 
                            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
                            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
                            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE
                            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
                            WHERE 1=1 AND is_visible = 'Y' AND SUB_ATT.ID_ACTION <> 7
                            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'  
                    	) rol ON rol.id_user = u.ID_USER
                            AND ( 
                                (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP =  tmp.id_group AND rol.ID_ELEMENT = tmp.id_element)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP =  tmp.id_group AND rol.ID_ELEMENT IS NULL)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP IS NULL AND rol.ID_ELEMENT IS NULL)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT IS NULL AND rol.ID_GROUP IS NULL AND rol.ID_ELEMENT IS NULL)
                            )
                LEFT JOIN (SELECT  ur.ID_USER AS id_user, decode(rl.IS_VISIBLE, 'Y', rl.name, '' ) AS name,
                            ur.EXTERNAL_SOURCE_NAME AS ASSOCIATION_SOURCE,	ur.EXTERNAL_ROLE_NAME AS ASSOCIATION_ROLE,
                            RES.ID_AREA,  SUB_ATT.ID_CONTEXT, RES.ID_GROUP , RES.ID_ELEMENT
                            FROM ROLE RL 
                            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
                            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
                            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE
                            INNER JOIN MYRPTS_ELEMENT_RELATION e ON e.ID_ELEMENT = RES.ID_ELEMENT
                            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
                            WHERE 1=1 AND is_visible = 'N' AND SUB_ATT.ID_ACTION <> 7
                            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'  
                            ) security ON security.id_user = u.ID_USER
                            AND ( 
                                (security.ID_AREA =  tmp.id_area AND security.ID_CONTEXT =  tmp.id_region AND security.ID_GROUP =  tmp.id_group AND security.ID_ELEMENT = tmp.id_element)
                            )	
             LEFT JOIN MYRPTS_REMEDY_SERVICE_REQUEST rem 
             on rem.ID_PRODUCT = tmp.id_product AND upper(rem.REQUEST_FOR_ISID) = UPPER(u.username)
             LEFT JOIN MYRPTS_SERVICE_NOW_REQUEST svcnow
			ON svcnow.ID_PRODUCT = tmp.id_product AND upper(svcnow.REQUEST_FOR_ISID) = UPPER(u.username)
             WHERE msa.ID_CONTEXT =  tmp.id_region
             AND mr.ID_AREA = tmp.id_area
             AND mr.ID_GROUP =  tmp.id_group
             AND mr.ID_ELEMENT = tmp.id_element
             AND u.ACTIVE = 'Y'
			 AND u.ID_USER = tmp.id_user
             AND orig.REMOVE_DATE IS NULL
			 AND (svcnow.ID_PRODUCT IS NULL OR svcnow.REQUEST_DATE IN (
				SELECT MAX(sn.REQUEST_DATE)
				FROM MYRPTS_SERVICE_NOW_REQUEST sn
				WHERE sn.ID_PRODUCT = tmp.id_product AND upper(sn.REQUEST_FOR_ISID) = UPPER(U.username)
			))
             AND NOT EXISTS (SELECT 1 FROM USER_ROLE us where us.ID_ROLE = 10 AND us.ACTIVE = 'Y' AND us.ID_USER = u.ID_USER)
        UNION
            SELECT
                'GROUP' HIERARCHY,
                msa.id_action,
                ma.DESCRIPTION action,
                msa.id_context,
                msrg.id_user,
                u.login,
                u.LAST_NAME,
                u.FIRST_NAME,
                u.EMAIL,        
                u.active,
                NVL(employee.REGION_NAME, '') AS REGION_NAME,
                NVL(employee.POSITION_DESCRIPTION, '')  AS POSITION_DESCRIPTION,
                mr.id_area,
                mr.id_group,
                mr.id_element,
                msrg.id_role,
                u.DIVISION_NAME,
                rol.name role_myreports,
                rol.ASSOCIATION_SOURCE source_role,
                rol.ASSOCIATION_ROLE profile_role, 
                security.ASSOCIATION_ROLE security_group,
                (SELECT als.description from USER_SEGMENT us		         
                    inner JOIN ACCESS_LINK_SEGMENT als
                    ON als.ID_SEGMENT = us.ID_SEGMENT AND als.ID_PRODUCT = tmp.id_product
                    WHERE   us.ID_USER = u.ID_USER) AS segment,  
                decode(rem.ID_PRODUCT, NULL, 'N', 'Y') remedy,
                decode(svcnow.ID_PRODUCT, NULL, 'N', DECODE(svcnow.ACTION_REQUESTED, 'Remove', 'N' ,'Y')) service_now,
                (SELECT max(logaux.date_action) as last_access  
                                        FROM si_log logaux 
                                       WHERE logaux.user_name = u.username
                                         AND logaux.operation = 'reportAccess'
                                         AND logaux.object_action = tmp.id_product) AS last_access,
				decode(orig.ISID_APPROVER, NULL, '', assigner.LAST_NAME || ', ' || assigner.FIRST_NAME || ' (' || orig.ISID_APPROVER || ')') AS ISID_APPROVER,
				orig.PERMISSION_TYPE 
            FROM
                myrpts_subject_attribute msa
                INNER JOIN myrpts_action ma ON msa.id_action = ma.id_action
                INNER JOIN myrpts_subject_relation msrg ON msa.id_subject = msrg.id_subject
                INNER JOIN usr u ON msrg.id_user = u.id_user
                INNER JOIN Temp_ tmp ON u.id_user = tmp.id_user
                INNER JOIN myrpts_resources mr ON msa.id_resource = mr.id_resource
				LEFT JOIN MYRPTS_PERMISSION_ORIG orig ON (orig.ID_RESOURCE = mr.ID_RESOURCE AND orig.ID_SUBJECT = msrg.ID_SUBJECT)
                LEFT JOIN usr assigner ON (assigner.id_user = orig.ID_USER_APPROVER)
                LEFT JOIN MYRPTS_COMPANY_EMPLOYEE employee ON employee.ID_USER = u.ID_USER
                LEFT JOIN (SELECT  ur.ID_USER AS id_user, decode(rl.IS_VISIBLE, 'Y', rl.name, '' ) AS name,
                            ur.EXTERNAL_SOURCE_NAME AS ASSOCIATION_SOURCE,	ur.EXTERNAL_ROLE_NAME AS ASSOCIATION_ROLE,
                            RES.ID_AREA,  SUB_ATT.ID_CONTEXT, RES.ID_GROUP , RES.ID_ELEMENT
                            FROM ROLE RL 
                            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
                            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
                            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE
                            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
                            WHERE 1=1 AND is_visible = 'Y' AND SUB_ATT.ID_ACTION <> 7
                            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'  
                    	) rol ON rol.id_user = u.ID_USER
                            AND ( 
                                (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP =  tmp.id_group AND rol.ID_ELEMENT = tmp.id_element)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP =  tmp.id_group AND rol.ID_ELEMENT IS NULL)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP IS NULL AND rol.ID_ELEMENT IS NULL)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT IS NULL AND rol.ID_GROUP IS NULL AND rol.ID_ELEMENT IS NULL)
                            ) 
                LEFT JOIN (SELECT  ur.ID_USER AS id_user, decode(rl.IS_VISIBLE, 'Y', rl.name, '' ) AS name,
                            ur.EXTERNAL_SOURCE_NAME AS ASSOCIATION_SOURCE,	ur.EXTERNAL_ROLE_NAME AS ASSOCIATION_ROLE,
                            RES.ID_AREA,  SUB_ATT.ID_CONTEXT, RES.ID_GROUP , RES.ID_ELEMENT
                            FROM ROLE RL 
                            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
                            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
                            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE
                            INNER JOIN MYRPTS_ELEMENT_RELATION e ON e.ID_ELEMENT = RES.ID_ELEMENT
                            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
                            WHERE 1=1 AND is_visible = 'N' AND SUB_ATT.ID_ACTION <> 7
                            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'  
                            ) security ON security.id_user = u.ID_USER
                            AND ( 
                                (security.ID_AREA =  tmp.id_area AND security.ID_CONTEXT =  tmp.id_region AND security.ID_GROUP =  tmp.id_group AND security.ID_ELEMENT = tmp.id_element)
                            )	
                 LEFT JOIN MYRPTS_REMEDY_SERVICE_REQUEST rem 
                 on rem.ID_PRODUCT = tmp.id_product AND upper(rem.REQUEST_FOR_ISID) = UPPER(u.username)
                 LEFT JOIN MYRPTS_SERVICE_NOW_REQUEST svcnow
				ON svcnow.ID_PRODUCT = tmp.id_product AND upper(svcnow.REQUEST_FOR_ISID) = UPPER(U.username)
             WHERE msa.ID_CONTEXT =  tmp.id_region
             AND mr.ID_AREA = tmp.id_area
             AND mr.ID_GROUP =  tmp.id_group
             AND mr.ID_ELEMENT IS NULL 
             AND u.ACTIVE = 'Y'
			 AND u.ID_USER = tmp.id_user
             AND orig.REMOVE_DATE IS NULL
			 AND (svcnow.ID_PRODUCT IS NULL OR svcnow.REQUEST_DATE IN (
				SELECT MAX(sn.REQUEST_DATE)
				FROM MYRPTS_SERVICE_NOW_REQUEST sn
				WHERE sn.ID_PRODUCT = tmp.id_product AND upper(sn.REQUEST_FOR_ISID) = UPPER(U.username)
			 ))
             AND NOT EXISTS (SELECT
                    1   
                FROM
                    myrpts_subject_attribute msa
                    INNER JOIN myrpts_subject_relation msr ON msa.id_subject = msr.id_subject
                    INNER JOIN myrpts_resources mr ON msa.id_resource = mr.id_resource
                 WHERE msa.ID_CONTEXT =  tmp.id_region
                 AND mr.ID_AREA = tmp.id_area
                 AND mr.ID_GROUP = tmp.id_group
                 AND mr.ID_ELEMENT = tmp.id_element
                 AND msr.ID_USER = msrg.ID_USER)
             AND NOT EXISTS (SELECT 1 FROM USER_ROLE us where us.ID_ROLE = 10 AND us.ACTIVE = 'Y' AND us.ID_USER = u.ID_USER)
        UNION
            SELECT
                decode(rl.IS_VISIBLE, 'Y', 'ROLE', 'SECURITY_GROUP' ) AS HIERARCHY, 6, 'Read' ACTION, SUB_ATT.ID_CONTEXT, USR.ID_USER, USR.LOGIN, USR.LAST_NAME, 
                USR.FIRST_NAME, USR.EMAIL, USR.ACTIVE,	NVL(employee.REGION_NAME, '') AS REGION_NAME, NVL(employee.POSITION_DESCRIPTION, '') AS POSITION_DESCRIPTION, RES.ID_AREA, 
                RES.ID_GROUP, RES.ID_ELEMENT, rl.ID_ROLE, usr.DIVISION_NAME, decode(rl.IS_VISIBLE, 'Y', rl.name, '' ),
                ur.EXTERNAL_SOURCE_NAME,	ur.EXTERNAL_ROLE_NAME, security.ASSOCIATION_ROLE AS security_group,
                (SELECT als.description from USER_SEGMENT us		         
                    inner JOIN ACCESS_LINK_SEGMENT als
                    ON als.ID_SEGMENT = us.ID_SEGMENT AND als.ID_PRODUCT = tmp.id_product
                    WHERE   us.ID_USER = usr.ID_USER) AS segment, 
                decode(rem.ID_PRODUCT, NULL, 'N', 'Y') remedy,
                decode(svcnow.ID_PRODUCT, NULL, 'N', DECODE(svcnow.ACTION_REQUESTED, 'Remove', 'N' ,'Y')) service_now,
                (SELECT max(logaux.date_action) as last_access  
                                        FROM si_log logaux 
                                       WHERE logaux.user_name = usr.username
                                         AND logaux.operation = 'reportAccess'
                                         AND logaux.object_action = tmp.id_product) AS last_access,
				decode(orig.ISID_APPROVER, NULL, '', assigner.LAST_NAME || ', ' || assigner.FIRST_NAME || ' (' || orig.ISID_APPROVER || ')') AS ISID_APPROVER,
				orig.PERMISSION_TYPE
            FROM ROLE RL 
            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE			
            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
            LEFT JOIN MYRPTS_PERMISSION_ORIG orig ON (orig.ID_ROLE = RL.ID_ROLE)
            LEFT JOIN usr assigner ON (assigner.id_user = orig.ID_USER_APPROVER)
            INNER JOIN USR ON ur.ID_USER = USR.ID_USER 
            INNER JOIN Temp_ tmp ON usr.id_user = tmp.id_user
            LEFT JOIN MYRPTS_COMPANY_EMPLOYEE employee ON employee.ID_USER = usr.ID_USER
			LEFT JOIN (SELECT  ur.ID_USER AS id_user, decode(rl.IS_VISIBLE, 'Y', rl.name, '' ) AS name,
                            ur.EXTERNAL_SOURCE_NAME AS ASSOCIATION_SOURCE,	ur.EXTERNAL_ROLE_NAME AS ASSOCIATION_ROLE,
                            RES.ID_AREA,  SUB_ATT.ID_CONTEXT, RES.ID_GROUP , RES.ID_ELEMENT
                            FROM ROLE RL 
                            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
                            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
                            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE
                            INNER JOIN MYRPTS_ELEMENT_RELATION e ON e.ID_ELEMENT = RES.ID_ELEMENT
                            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
                            WHERE 1=1 AND is_visible = 'N' AND SUB_ATT.ID_ACTION <> 7
                            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'  
                            ) security ON security.id_user = ur.ID_USER
                            AND ( 
                                (security.ID_AREA =  tmp.id_area AND security.ID_CONTEXT =  tmp.id_region AND security.ID_GROUP =  tmp.id_group AND security.ID_ELEMENT = tmp.id_element)
                            )	
            LEFT JOIN ACCESS_LINK_SEGMENT als
            ON als.ID_PRODUCT = tmp.id_product
            LEFT JOIN USER_SEGMENT us
            ON us.ID_USER = USR.ID_USER AND als.ID_SEGMENT = us.ID_SEGMENT
             LEFT JOIN MYRPTS_REMEDY_SERVICE_REQUEST rem 
             on rem.ID_PRODUCT = tmp.id_product AND upper(rem.REQUEST_FOR_ISID) = UPPER(USR.username)
			LEFT JOIN MYRPTS_SERVICE_NOW_REQUEST svcnow
			ON svcnow.ID_PRODUCT = tmp.id_product AND upper(svcnow.REQUEST_FOR_ISID) = UPPER(USR.username) 
            WHERE 1=1 AND is_visible = 'Y' AND SUB_ATT.ID_ACTION <> 7 AND ur.ACTIVE = 'Y' AND usr.ACTIVE = 'Y' AND usr.ID_USER = tmp.id_user
            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'
            AND ((orig.REMOVE_DATE IS NULL AND 
            ((orig.ACTION_TYPE = 'S' AND ur.EXTERNAL_SOURCE_NAME = orig.EXTERNAL_SOURCE_NAME AND ur.EXTERNAL_ROLE_NAME = orig.EXTERNAL_ROLE_NAME) 
            OR (orig.ACTION_TYPE = 'R' AND orig.ID_USER_ASSIGNED = ur.ID_USER))) OR ORIG.PERMISSION_TYPE IS NULL)
			AND (svcnow.ID_PRODUCT IS NULL OR svcnow.REQUEST_DATE IN (
				SELECT MAX(sn.REQUEST_DATE)
				FROM MYRPTS_SERVICE_NOW_REQUEST sn
				WHERE sn.ID_PRODUCT = tmp.id_product AND upper(sn.REQUEST_FOR_ISID) = UPPER(USR.username)
			))
            AND ( 
                (RES.ID_AREA =  tmp.id_area AND SUB_ATT.ID_CONTEXT =  tmp.id_region AND RES.ID_GROUP =  tmp.id_group AND RES.ID_ELEMENT = tmp.id_element)
                OR  (RES.ID_AREA =  tmp.id_area AND SUB_ATT.ID_CONTEXT =  tmp.id_region AND RES.ID_GROUP =  tmp.id_group AND RES.ID_ELEMENT IS NULL)
                OR  (RES.ID_AREA =  tmp.id_area AND SUB_ATT.ID_CONTEXT =  tmp.id_region AND RES.ID_GROUP IS NULL AND RES.ID_ELEMENT IS NULL)
                OR  (RES.ID_AREA =  tmp.id_area AND SUB_ATT.ID_CONTEXT IS NULL AND RES.ID_GROUP IS NULL AND RES.ID_ELEMENT IS NULL)
            )	
            AND NOT EXISTS (SELECT
                    1   
                FROM
                    myrpts_subject_attribute msa
                    INNER JOIN myrpts_subject_relation msr ON msa.id_subject = msr.id_subject
                    INNER JOIN myrpts_resources mr ON msa.id_resource = mr.id_resource
                 WHERE msa.ID_CONTEXT =  tmp.id_region
                 AND mr.ID_AREA = tmp.id_area
                 AND mr.ID_GROUP = tmp.id_group
                 AND mr.ID_ELEMENT = tmp.id_element
                 AND msr.ID_USER = usr.ID_USER)
            AND NOT EXISTS (SELECT
                    1   
                FROM
                    myrpts_subject_attribute msa
                    INNER JOIN myrpts_subject_relation msr ON msa.id_subject = msr.id_subject
                    INNER JOIN myrpts_resources mr ON msa.id_resource = mr.id_resource
                 WHERE msa.ID_CONTEXT =  tmp.id_region
                 AND mr.ID_AREA = tmp.id_area
                 AND mr.ID_GROUP = tmp.id_group
                 AND mr.ID_ELEMENT IS null
                 AND msr.ID_USER = usr.ID_USER)
        UNION
            SELECT DISTINCT
                decode(rl.IS_VISIBLE, 'Y', 'ROLE', 'SECURITY_GROUP' ) AS HIERARCHY, 6, 'Read' ACTION, SUB_ATT.ID_CONTEXT, USR.ID_USER, USR.LOGIN, USR.LAST_NAME, 
                USR.FIRST_NAME, USR.EMAIL, USR.ACTIVE,	NVL(employee.REGION_NAME, '') AS REGION_NAME, NVL(employee.POSITION_DESCRIPTION, '') AS POSITION_DESCRIPTION, RES.ID_AREA, 
                RES.ID_GROUP, RES.ID_ELEMENT, rl.ID_ROLE, usr.DIVISION_NAME, decode(rol.name, '', '', rol.name),
                rol.ASSOCIATION_SOURCE source_role,	rol.ASSOCIATION_ROLE profile_role, ur.EXTERNAL_ROLE_NAME security_group, 
                (SELECT als.description from USER_SEGMENT us		         
                    inner JOIN ACCESS_LINK_SEGMENT als
                    ON als.ID_SEGMENT = us.ID_SEGMENT AND als.ID_PRODUCT = tmp.id_product
                    WHERE   us.ID_USER = usr.ID_USER) AS segment, 
                decode(rem.ID_PRODUCT, NULL, 'N', 'Y') remedy,
                decode(svcnow.ID_PRODUCT, NULL, 'N', DECODE(svcnow.ACTION_REQUESTED, 'Remove', 'N' ,'Y')) service_now,
                (SELECT max(logaux.date_action) as last_access  
                                        FROM si_log logaux 
                                       WHERE logaux.user_name = usr.username
                                         AND logaux.operation = 'reportAccess'
                                         AND logaux.object_action = tmp.id_product) AS last_access,
				decode(orig.ISID_APPROVER, NULL, '', assigner.LAST_NAME || ', ' || assigner.FIRST_NAME || ' (' || orig.ISID_APPROVER || ')') AS ISID_APPROVER,
				orig.PERMISSION_TYPE
            FROM ROLE RL 
            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE
			LEFT JOIN MYRPTS_PERMISSION_ORIG orig ON (orig.ID_ROLE = RL.ID_ROLE)
            LEFT JOIN usr assigner ON (assigner.id_user = orig.ID_USER_APPROVER)
            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
            INNER JOIN USR ON ur.ID_USER = USR.ID_USER 
            INNER JOIN Temp_ tmp ON usr.id_user = tmp.id_user
            LEFT JOIN MYRPTS_COMPANY_EMPLOYEE employee ON employee.ID_USER = usr.ID_USER
            LEFT JOIN ACCESS_LINK_SEGMENT als
            ON als.ID_PRODUCT = tmp.id_product
            LEFT JOIN USER_SEGMENT us
            ON us.ID_USER = USR.ID_USER AND als.ID_SEGMENT = us.ID_SEGMENT
             LEFT JOIN MYRPTS_REMEDY_SERVICE_REQUEST rem 
             on rem.ID_PRODUCT = tmp.id_product AND upper(rem.REQUEST_FOR_ISID) = UPPER(USR.username)
            LEFT JOIN MYRPTS_SERVICE_NOW_REQUEST svcnow
			ON svcnow.ID_PRODUCT = tmp.id_product AND upper(svcnow.REQUEST_FOR_ISID) = UPPER(USR.username)
            LEFT JOIN (SELECT  ur.ID_USER AS id_user, decode(rl.IS_VISIBLE, 'Y', rl.name, '' ) AS name,
                            ur.EXTERNAL_SOURCE_NAME AS ASSOCIATION_SOURCE,	ur.EXTERNAL_ROLE_NAME AS ASSOCIATION_ROLE,
                            RES.ID_AREA,  SUB_ATT.ID_CONTEXT, RES.ID_GROUP , RES.ID_ELEMENT
                            FROM ROLE RL 
                            INNER JOIN MYRPTS_SUBJECT_RELATION SUB_REL ON RL.ID_ROLE = SUB_REL.ID_ROLE 
                            INNER JOIN MYRPTS_SUBJECT_ATTRIBUTE SUB_ATT ON SUB_REL.ID_SUBJECT = SUB_ATT.ID_SUBJECT 
                            INNER JOIN MYRPTS_RESOURCES RES ON RES.ID_RESOURCE = SUB_ATT.ID_RESOURCE
                            INNER JOIN USER_ROLE ur ON ur.ID_ROLE = rl.ID_ROLE AND ur.ACTIVE = 'Y'
                            WHERE 1=1 AND is_visible = 'Y' AND SUB_ATT.ID_ACTION <> 7
                            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'  
                    	) rol ON rol.id_user = ur.ID_USER
                            AND ( 
                                (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP =  tmp.id_group AND rol.ID_ELEMENT = tmp.id_element)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP =  tmp.id_group AND rol.ID_ELEMENT IS NULL)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT =  tmp.id_region AND rol.ID_GROUP IS NULL AND rol.ID_ELEMENT IS NULL)
                                OR  (rol.ID_AREA =  tmp.id_area AND rol.ID_CONTEXT IS NULL AND rol.ID_GROUP IS NULL AND rol.ID_ELEMENT IS NULL)
                            ) 
            WHERE 1=1 AND is_visible = 'N' AND SUB_ATT.ID_ACTION <> 7 AND ur.ACTIVE = 'Y' AND usr.ACTIVE = 'Y' AND usr.ID_USER = tmp.id_user
            AND RL.ID_ROLE NOT IN (10,4) AND RL.STATUS IS NOT NULL AND RL.STATUS = 'A'
            AND ((orig.REMOVE_DATE IS NULL AND orig.ACTION_TYPE = 'S' AND ur.EXTERNAL_SOURCE_NAME = orig.EXTERNAL_SOURCE_NAME 
            AND ur.EXTERNAL_ROLE_NAME = orig.EXTERNAL_ROLE_NAME) OR ORIG.PERMISSION_TYPE IS NULL)
			AND (svcnow.ID_PRODUCT IS NULL OR svcnow.REQUEST_DATE IN (
				SELECT MAX(sn.REQUEST_DATE)
				FROM MYRPTS_SERVICE_NOW_REQUEST sn
				WHERE sn.ID_PRODUCT = tmp.id_product AND upper(sn.REQUEST_FOR_ISID) = UPPER(USR.username)
			))
            AND ( 
                (RES.ID_AREA =  tmp.id_area AND SUB_ATT.ID_CONTEXT =  tmp.id_region AND RES.ID_GROUP =  tmp.id_group AND RES.ID_ELEMENT = tmp.id_element)
            )	
            AND NOT EXISTS (SELECT
                    1   
                FROM
                    myrpts_subject_attribute msa
                    INNER JOIN myrpts_subject_relation msr ON msa.id_subject = msr.id_subject
                    INNER JOIN myrpts_resources mr ON msa.id_resource = mr.id_resource
                 WHERE msa.ID_CONTEXT =  tmp.id_region
                 AND mr.ID_AREA = tmp.id_area
                 AND mr.ID_GROUP = tmp.id_group
                 AND mr.ID_ELEMENT = tmp.id_element
                 AND msr.ID_USER = usr.ID_USER)
            AND NOT EXISTS (SELECT
                    1   
                FROM
                    myrpts_subject_attribute msa
                    INNER JOIN myrpts_subject_relation msr ON msa.id_subject = msr.id_subject
                    INNER JOIN myrpts_resources mr ON msa.id_resource = mr.id_resource
                 WHERE msa.ID_CONTEXT =  tmp.id_region
                 AND mr.ID_AREA = tmp.id_area
                 AND mr.ID_GROUP = tmp.id_group
                 AND mr.ID_ELEMENT IS null
                 AND msr.ID_USER = usr.ID_USER)
            ) result 
        ORDER BY TRIM(result.LAST_NAME) ASC, result.security_group ASC