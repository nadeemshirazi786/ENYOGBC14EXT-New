table 14229439 "Recipient Agency ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New table
    //    - renumbered
    // 
    // ENRE1.00
    //    - lookupid/drilldownid update

    DrillDownPageID = "Recipient Agencies ELA"; //Recipient Agencies
    LookupPageID = "Recipient Agencies ELA";

    fields
    {
        field(1; "No."; Code[20])
        {
            NotBlank = true;
        }
        field(2; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            NotBlank = true;
            TableRelation = "Country/Region";
        }
        field(3; County; Text[30])
        {
            Caption = 'State';
            NotBlank = true;
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;

            trigger OnLookup()
            begin
                //TrgrecCounty.LookUpLegacyCounty(County,"Country/Region Code",TRUE);
            end;

            trigger OnValidate()
            begin
                //TRgrecCounty.ValidateLegacyCounty(County,"Country/Region Code");
            end;
        }
        field(4; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(5; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(6; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                grecPostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(8; Contact; Text[100])
        {
            Caption = 'Contact';

            trigger OnValidate()
            begin
                TestField("Primary Contact No.", '');
                if "Company Contact No." = '' then begin
                    if not Confirm(Text001) then begin
                        Error(Text002);
                    end;
                end;


                if (xRec.Contact = '') and (xRec."Primary Contact No." = '') then begin
                    Modify;
                    RMSetup.Get;
                    if "Company Contact No." = '' then begin

                        Cont.Init;
                        Cont.Name := Rec.Name;
                        Cont.Address := Rec.Address;
                        Cont."Address 2" := Rec."Address 2";
                        Cont.City := Rec.City;
                        Cont."Phone No." := Rec."Phone No.";
                        Cont."Fax No." := Rec."Fax No.";
                        Cont."Post Code" := Rec."Post Code";
                        Cont."E-Mail" := Rec."E-Mail";
                        Cont.County := Rec.County;
                        Cont."Country/Region Code" := Rec."Country/Region Code";

                        Cont.Validate(Name);
                        Cont.Validate("E-Mail");
                        Cont."No." := '';
                        Cont."No. Series" := '';
                        RMSetup.TestField("Contact Nos.");
                        NoSeriesMgt.InitSeries(RMSetup."Contact Nos.", '', 0D, "No.", Cont."No. Series");
                        Cont.Type := Cont.Type::Company;
                        Cont.TypeChange;
                        Cont.Insert(true);
                        Rec.Validate("Company Contact No.", Cont."No.");


                    end;


                    Cont2.Init;
                    Cont2.Name := Contact;
                    Cont2.Address := Rec.Address;
                    Cont2."Address 2" := Rec."Address 2";
                    Cont2.City := Rec.City;
                    Cont2."Phone No." := Rec."Phone No.";
                    Cont2."Fax No." := Rec."Fax No.";
                    Cont2."Post Code" := Rec."Post Code";
                    Cont2."E-Mail" := Rec."E-Mail";
                    Cont2.County := Rec.County;
                    Cont2."Country/Region Code" := Rec."Country/Region Code";

                    Cont2.Validate(Name);
                    Cont2.Validate("E-Mail");
                    Cont2."No." := '';
                    Cont2."No. Series" := '';
                    RMSetup.TestField("Contact Nos.");
                    NoSeriesMgt.InitSeries(RMSetup."Contact Nos.", '', 0D, "No.", Cont2."No. Series");
                    Cont2.Type := Cont.Type::Person;
                    Cont.TypeChange;
                    if "Company Contact No." = '' then begin
                        Cont2."Company No." := Cont."No.";
                        Cont2."Company Name" := Cont.Name;
                    end else begin
                        Cont2.Validate("Company No.", "Company Contact No.");
                    end;

                    Cont2.Insert(true);
                    Rec.Validate("Primary Contact No.", Cont2."No.");

                    Modify(true);
                end;
            end;
        }
        field(9; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(84; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
        }
        field(91; "Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                //TRgrecPostCode.ValidatePostCode(City,"Post Code",County,"Country/Region Code",(CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(102; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
        }
        field(5048; "Company Contact No."; Code[20])
        {
            Caption = 'Company Contact No.';
            TableRelation = Contact WHERE(Type = CONST(Company));

            trigger OnValidate()
            begin
                if "Company Contact No." = '' then begin
                    "Primary Contact No." := '';
                    Contact := '';
                end;
            end;
        }
        field(5049; "Primary Contact No."; Code[20])
        {
            Caption = 'Primary Contact No.';
            TableRelation = Contact WHERE(Type = CONST(Person));

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusRel: Record "Contact Business Relation";
            begin

                if "Company Contact No." <> '' then begin
                    if "Primary Contact No." <> '' then
                        if Cont.Get("Primary Contact No.") then;
                    Cont.SetFilter(Type, '%1', Cont.Type::Person);
                    if PAGE.RunModal(0, Cont) = ACTION::LookupOK then
                        Validate("Primary Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                ContBusRel: Record "Contact Business Relation";
            begin
                Contact := '';
                if "Primary Contact No." <> '' then begin
                    Cont.Get("Primary Contact No.");
                    Cont.TestField(Type, Cont.Type::Person);
                    Contact := Cont.Name
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "No.", "Country/Region Code", County)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        grecRACommentLine.SetRange("Table Name", grecRACommentLine."Table Name"::"Recipient Agency");
        grecRACommentLine.SetRange("No.", "No.");
        grecRACommentLine.SetRange("Country/Region Code", "Country/Region Code");
        grecRACommentLine.SetRange(County, County);
        grecRACommentLine.DeleteAll;
    end;

    trigger OnRename()
    begin

        grecRACommentLine.SetRange("Table Name", grecRACommentLine."Table Name"::"Recipient Agency");
        grecRACommentLine.SetRange("No.", xRec."No.");
        grecRACommentLine.SetRange("Country/Region Code", xRec."Country/Region Code");
        grecRACommentLine.SetRange(County, xRec.County);
        if grecRACommentLine.FindSet then begin
            repeat
                grecRACommentLine2.TransferFields(grecRACommentLine);
                grecRACommentLine2."No." := "No.";
                grecRACommentLine2."Country/Region Code" := "Country/Region Code";
                grecRACommentLine2.County := County;
                grecRACommentLine2.Insert;
            until grecRACommentLine.Next = 0;
        end;
        grecRACommentLine.Reset;
        grecRACommentLine.SetRange("Table Name", grecRACommentLine."Table Name"::"Recipient Agency");
        grecRACommentLine.SetRange("No.", xRec."No.");
        grecRACommentLine.SetRange("Country/Region Code", xRec."Country/Region Code");
        grecRACommentLine.SetRange(County, xRec.County);
        grecRACommentLine.DeleteAll;
    end;

    var
        grecPostCode: Record "Post Code";
        grecRACommentLine: Record "Reci. Agency Comment Line ELA";
        grecRACommentLine2: Record "Reci. Agency Comment Line ELA";
        Cont: Record Contact;
        Cont2: Record Contact;
        RMSetup: Record "Marketing Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text001: Label 'No Company Contact has been selected. A Company and\a Person Contact will be created. Do you wish to continue?';
        Text002: Label 'No contacts were created.';
}

