table 14228812 County
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF02278AC
    //   20090616
    //     - new object
    // 
    // JF14440MG
    //   20110909 - add code to support lookups for County fields (both legacy and JF fields)

    Caption = 'State';
    LookupPageID = Counties;

    fields
    {
        field(1; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            NotBlank = true;
            TableRelation = "Country/Region";
        }
        field(2;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3;Name;Text[50])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"Country/Region Code","Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    [Scope('Internal')]
    procedure jfConvertLegacyCounty(ptxtLegacyCounty: Text[30]): Code[10]
    var
        lcodCounty: Code[10];
    begin
        //<JF14440MG>
        lcodCounty := COPYSTR(ptxtLegacyCounty,1,10);
        EXIT(lcodCounty);
        //<</JF14440MG>
    end;

    [Scope('Internal')]
    procedure jfValidateLegacyCounty(var ptxtCounty: Text[30];var pcodCountry: Code[10])
    var
        lrecCounty: Record County;
        lrecCounty2: Record County;
        lcodCounty: Code[10];
        ltxt000: Label '%1 is not a valid %2.';
    begin
        //<JF14440MG>
        //-- Use this function if adding validation capability for a legacy (e.g. Text30) County field
        lcodCounty := jfConvertLegacyCounty(ptxtCounty);
        jfValidateCounty(lcodCounty,pcodCountry);
        ptxtCounty := lcodCounty;
        //</JF14440MG>
    end;

    [Scope('Internal')]
    procedure jfLookUpLegacyCounty(var ptxtCounty: Text[30];var pcodCountry: Code[10];ReturnValues: Boolean)
    var
        lrecCounty: Record County;
        lcodCounty: Code[10];
    begin
        //<JF14440MG>
        //-- Use this function if adding lookup capability for a legacy (e.g. Text30) County field
        lcodCounty := jfConvertLegacyCounty(ptxtCounty);
        jfLookUpCounty(lcodCounty,pcodCountry,ReturnValues);

        IF ReturnValues THEN
          ptxtCounty := lcodCounty;
        //</JF14440MG>
    end;

    [Scope('Internal')]
    procedure jfValidateCounty(var pcodCounty: Code[10];var pcodCountry: Code[10])
    var
        lrecCounty: Record County;
        lrecCounty2: Record County;
        ltxt000: Label '%1 is not a valid %2.';
    begin
        //<JF14440MG>
        IF pcodCounty <> '' THEN BEGIN
          lrecCounty.SETRANGE(Code,pcodCounty);

          IF NOT lrecCounty.FINDSET THEN
            ERROR(ltxt000,pcodCounty,lrecCounty.TABLECAPTION);

          lrecCounty2.COPY(lrecCounty);

          IF (lrecCounty2.NEXT = 1) AND GUIALLOWED THEN
            IF PAGE.RUNMODAL(PAGE::Counties,lrecCounty,lrecCounty.Code) <> ACTION::LookupOK THEN
              EXIT;

          pcodCounty := lrecCounty.Code;
          pcodCountry := lrecCounty."Country/Region Code";
        END;
        //</JF14440MG>
    end;

    [Scope('Internal')]
    procedure jfLookUpCounty(var pcodCounty: Code[10];var pcodCountry: Code[10];ReturnValues: Boolean)
    var
        lrecCounty: Record County;
    begin
        //<JF14440MG>
        IF NOT GUIALLOWED THEN
          EXIT;

        lrecCounty.SETCURRENTKEY("Country/Region Code",Code);
        lrecCounty."Country/Region Code" := pcodCountry;
        lrecCounty.Code := pcodCounty;

        IF (PAGE.RUNMODAL(PAGE::Counties,lrecCounty,lrecCounty.Code) = ACTION::LookupOK) AND ReturnValues THEN BEGIN
          pcodCounty := lrecCounty.Code;
          pcodCountry := lrecCounty."Country/Region Code";
        END;
        //</JF14440MG>
    end;
}

