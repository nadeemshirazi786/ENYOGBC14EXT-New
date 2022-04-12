tableextension 14229607 "EN Customer ELA" extends "Customer"

{
    fields
    {
        field(14229400; "Rebate Group Code ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Rebate Group ELA";
            Caption = 'Rebate Group Code';

        }
        field(14229401; "Rebate Code Filter ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Rebate Header ELA";
            Caption = 'Rebate Code Filter';

        }
        field(14229403; "Recipient Agency No. ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Recipient Agency ELA"."No." WHERE("Country/Region Code" = FIELD("Country/Region Code"), County = FIELD(County));
            Caption = 'Recipient Agency No.';
        }
        field(14228850; "Price Rule Code ELA"; Code[10])
        {
            Caption = 'Price Rule Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Price Rule";
        }
        field(14228851; "Customer Buying Group ELA"; Code[20])
        {
            Caption = 'Customer Buying Group';
            DataClassification = ToBeClassified;
            TableRelation = "Customer Buying Group ELA";
        }
        field(14228852; "Price List Group Code ELA"; Code[20])
        {
            Caption = 'Price List Group Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Price List Group";
        }
        field(14228853; "Sales Price/Sur Date Cntrl ELA"; Enum "EN Sales Price/Sur. Date Control")
        {
            Caption = 'Sales Price/Sur. Date Control';
            DataClassification = ToBeClassified;
        }
        field(14228854; "Sales Price UOM ELA"; Code[10])
        {
            Caption = 'Sales Price Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure".Code;
        }
        field(14228855; "Sell Items at Cost ELA"; Boolean)
        {
            Caption = 'Sell Items at Cost';
        }
        field(14228856; "Sales Unit of Measure ELA"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure".Code;
        }
        field(14228857; "Order Rule Group ELA"; Code[20])
        {
            Caption = 'Order Rule Group';
            TableRelation = "EN Order Rule Group";
        }
        field(14228858; "Order Rule Usage ELA"; Enum "EN Order Rule Usage")
        {
            Caption = 'Order Rule Usage';

        }
        field(14228859; "Campaign No. ELA"; Code[20])
        {
            Caption = 'Campaign No.';
            TableRelation = Campaign;

        }
        field(14228880; "Credit Grace Period (Days) ELA"; Integer)
        {
            Caption = 'Credit Grace Period (Days)';
            DataClassification = ToBeClassified;
        }
        field(14228881; "Use Backorder Tolerance ELA"; Boolean)
        {
            Caption = 'Use Backorder Tolerance';
            DataClassification = ToBeClassified;
        }
        field(14228882; "Backorder Tolerance % ELA"; Decimal)
        {
            Caption = 'Backorder Tolerance %';
            DecimalPlaces = 0 : 5;
            BlankZero = true;
            DataClassification = ToBeClassified;
        }
        field(14228883; "Req. Ship-To on Sale Doc ELA"; Boolean)
        {
            Caption = 'Require Ship-to on Sales Docs';
            DataClassification = ToBeClassified;
        }
        field(14228900; "Direct Customer ELA"; Boolean)
        {
            Caption = 'Direct Customer';
            DataClassification = ToBeClassified;
        }
        field(50000; "Require Ext. Doc. No."; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Require Ext. Doc. No.';
        }
        field(50001; "MB Export Store No."; Text[3])
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Direct Store Delivery"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51003; "Banana Worksheet"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14228800; "Latitude ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 6 : 8;
        }
        field(14228801; "Longitude ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 6 : 8;
        }
        field(14228802; "Dropoff Time Window Start ELA"; Time)
        {
            Caption = 'Dropoff Time Window Start';
            DataClassification = ToBeClassified;
        }
        field(14228803; "Dropoff Time Window End ELA"; Time)
        {
            Caption = 'Dropoff Time Window End';
            DataClassification = ToBeClassified;
        }
        field(14228804; "Dropoff Time Window Start 2 ELA"; Time)
        {
            Caption = 'Dropoff time Window Start 2';
            DataClassification = ToBeClassified;
        }
        field(14228805; "Dropoff Time Window End 2 ELA"; Time)
        {
            Caption = 'Dropoff Time Window End 2';
            DataClassification = ToBeClassified;
        }
        field(14228806; "Required Vehicle ELA"; Code[20])
        {
            Caption = 'Required Vehicle';
            DataClassification = ToBeClassified;
            TableRelation = Resource."No." where(Type = CONST(Machine));
        }
        field(14228807; "Dropoff Required Tags ELA"; Code[20])
        {
            Caption = 'Dropoff Required Tags';
            DataClassification = ToBeClassified;
            TableRelation = "FA Class";
        }
        field(14228808; "Dropoff Banned Tags ELA"; Code[20])
        {
            Caption = 'Dropoff Banned Tags';
            DataClassification = ToBeClassified;
            TableRelation = "FA Class";
        }
        field(14228810; "Shipping Instructions ELA"; Text[80])
        {
            Caption = 'Shipping Instructions';
            DataClassification = ToBeClassified;
        }
        field(14229601; "Communication Group Code ELA"; Code[20])
        {
            Caption = 'Communication Group Code';
            TableRelation = "Communication Group ELA"."Code";
            DataClassification = ToBeClassified;
        }
        field(14229602; "Global Group 1 Code ELA"; Code[20])
        {
            Caption = 'Global Group 1 Code';
            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin

                IF "Global Group 1 Code ELA" <> '' THEN BEGIN
                    SalesSetup.GET;
                    SalesSetup.TESTFIELD("Global Group 1 Code ELA");
                    GlobalGroupValue.GET(SalesSetup."Global Group 1 Code ELA", "Global Group 1 Code ELA");
                END;

            end;

            trigger OnLookup()
            var
                GlobalGroupValues: Page "Global Group Values ELA";
                GlobalGroupValue: Record "Global Group Value ELA";
                SalesSetup: Record "Sales & Receivables Setup";
            begin
                SalesSetup.GET;
                SalesSetup.TESTFIELD("Global Group 1 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', SalesSetup."Global Group 1 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 1 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }

        field(14229603; "Global Group 2 Code ELA"; Code[20])
        {
            Caption = 'Global Group 2 Code';
            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 2 Code ELA" <> '' THEN BEGIN
                    SalesSetup.GET;
                    SalesSetup.TESTFIELD("Global Group 2 Code ELA");
                    GlobalGroupValue.GET(SalesSetup."Global Group 2 Code ELA", "Global Group 2 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValues: Page "Global Group Values ELA";
                GlobalGroupValue: Record "Global Group Value ELA";
                SalesSetup: Record "Sales & Receivables Setup";
            begin
                CLEAR(GlobalGroupValues);
                SalesSetup.GET;
                SalesSetup.TESTFIELD("Global Group 2 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', SalesSetup."Global Group 2 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 2 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(14229604; "Global Group 3 Code ELA"; Code[20])
        {
            Caption = 'Global Group 3 Code';
            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 3 Code ELA" <> '' THEN BEGIN
                    SalesSetup.GET;
                    SalesSetup.TESTFIELD("Global Group 3 Code ELA");
                    GlobalGroupValue.GET(SalesSetup."Global Group 3 Code ELA", "Global Group 3 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValues: Page "Global Group Values ELA";
                GlobalGroupValue: Record "Global Group Value ELA";
                SalesSetup: Record "Sales & Receivables Setup";
            begin

                CLEAR(GlobalGroupValues);
                SalesSetup.GET;
                SalesSetup.TESTFIELD("Global Group 3 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', SalesSetup."Global Group 3 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 3 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(14229605; "Global Group 4 Code ELA"; Code[20])
        {
            Caption = 'Global Group 4 Code';
            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 4 Code ELA" <> '' THEN BEGIN
                    SalesSetup.GET;
                    SalesSetup.TESTFIELD("Global Group 4 Code ELA");
                    GlobalGroupValue.GET(SalesSetup."Global Group 4 Code ELA", "Global Group 4 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValues: Page "Global Group Values ELA";
                GlobalGroupValue: Record "Global Group Value ELA";
                SalesSetup: Record "Sales & Receivables Setup";
            begin
                CLEAR(GlobalGroupValues);
                SalesSetup.GET;
                SalesSetup.TESTFIELD("Global Group 4 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', SalesSetup."Global Group 4 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 4 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(14229606; "Global Group 5 Code ELA"; Code[20])
        {
            Caption = 'Global Group 5 Code';
            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 5 Code ELA" <> '' THEN BEGIN
                    SalesSetup.GET;
                    SalesSetup.TESTFIELD("Global Group 5 Code ELA");
                    GlobalGroupValue.GET(SalesSetup."Global Group 5 Code ELA", "Global Group 5 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValues: Page "Global Group Values ELA";
                GlobalGroupValue: Record "Global Group Value ELA";
                SalesSetup: Record "Sales & Receivables Setup";
            begin

                CLEAR(GlobalGroupValues);
                SalesSetup.GET;
                SalesSetup.TESTFIELD("Global Group 5 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', SalesSetup."Global Group 5 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 5 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(14228809; "Delivery Zone Code ELA"; Code[20])
        {
            TableRelation = "Delivery Zone ELA".Code;
            Caption = 'Delivery Zone Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                lrecDeliveryZone: Record "Delivery Zone ELA";
            begin
                IF "Delivery Zone Code ELA" <> '' THEN BEGIN
                    lrecDeliveryZone.GET("Delivery Zone Code ELA");
                    lrecDeliveryZone.TESTFIELD(Type, lrecDeliveryZone.Type::Standard);
                END;
            end;
        }
        field(14228811; "Prices on Invoice ELA"; Boolean)
        {
            Caption = 'Prices on Invoice';
            DataClassification = ToBeClassified;
        }
        field(14229200; "Default Delivery Route ELA"; Code[20])
        {
            Caption = 'Default Delivery Route';
            TableRelation = "Delivery Route ELA";
            DataClassification = ToBeClassified;
        }
        field(14229201; "Default Stop No. ELA"; Integer)
        {
            Caption = 'Default Stop No.';
            DataClassification = ToBeClassified;
        }
        field(14229202; "Auto. Add to Outbound Load ELA"; Boolean)
        {
            Caption = 'Auto. Add to Outbound Load';
            DataClassification = ToBeClassified;
        }
    }
}