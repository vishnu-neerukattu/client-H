SELECT r.AccountKey
     , r.ContactKey
     , r.DefaultLanguageCode
     , LOWER(CONCAT(MHM.Hub,'_',r.CountryCode,'_',r.DefaultLanguageCode)) AS ParamUtmCampaign
     , LOWER(CONCAT(r.ShortIndustryCode,'_',r.CustomerClassification,'_',r.CodifiedPersona)) AS ParamCInfoCampaign
  FROM ( SELECT DISTINCT
           A.AccountKey
         , C.ContactKey
         , A.CountryCode
         , ACR.MarketCode
         , A.ShortIndustryCode
         , A.CustomerClassification
         , CASE
             WHEN LOWER(C.MarketingPersona) = 'manage business' THEN 'mbu'
             WHEN LOWER(C.MarketingPersona) = 'manage operations' THEN 'mop'
             WHEN LOWER(C.MarketingPersona) = 'buyer' THEN 'buy'
             WHEN LOWER(C.MarketingPersona) = 'safety manager' THEN 'saf'
             WHEN LOWER(C.MarketingPersona) = 'worker' THEN 'wor'
             ELSE 'other'
           END AS CodifiedPersona
         , CASE 
             WHEN C.PreferredLanguage IS NULL THEN 
               CASE 
                 WHEN OptionIsNull = 'Suppress' THEN Null 
                 ELSE MOPL.DefaultLanguageCode 
               END
             WHEN MOL.LanguageCode is null THEN
               CASE 
                 WHEN OptionNotMatched = 'Suppress' THEN Null
                 ELSE MOPL.DefaultLanguageCode 
               END
             ELSE PreferredLanguage 
           END AS DefaultLanguageCode
      FROM Import_ACR ACR
      JOIN MSD_Account A
        ON ACR.SAPAccountId = A.SAPAccountID
       AND ACR.MarketCode=A.MarketOrganization
        JOIN MSD_Account A
        ON ACR.SAPAccountId = A.SAPAccountID
       AND ACR.MarketCode=A.MarketOrganization
        JOIN MSD_Account A
        ON ACR.SAPAccountId = A.SAPAccountID
       AND ACR.MarketCode=A.MarketOrganization
      JOIN MSD_Contact C
        ON ACR.SAPContactId = C.SAPContactId
      JOIN MarketOrganisationLanguage MOL
        ON ACR.MarketCode=MOL.MarketOrganisation
      JOIN MarketOrganisationLanguagePref MOPL
        ON MOL.MarketOrganisation=MOPL.MarketOrganisation
        /*exclude accounts that are sourced from Sales Cloud*/
      LEFT JOIN MatchedAccount MA
             ON ACR.SAPAccountId = MA.SAPAccountId 
            AND ACR.MarketCode = MA.MarketCode
     WHERE MA.SalesforceAccountId is null ) r
  JOIN Market_Hub_Mapping MHM
     ON r.MarketCode = MHM.SalesOrg