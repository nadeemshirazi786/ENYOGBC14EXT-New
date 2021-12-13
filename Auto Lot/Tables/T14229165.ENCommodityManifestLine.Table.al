table 14229165 "EN Commodity Manifest Line ELA"
{
    Caption = 'Commodity Manifest Line';

    fields
    {
        field(1; "Commodity Manifest No."; Code[20])
        {
            Caption = 'Commodity Manifest No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';

            trigger OnValidate()
            begin
                TestField("Vendor No.");
                CalcFields("Vendor Name");
            end;
        }
        field(4; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Manifest Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Manifest Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(8; "Received Date"; Date)
        {
            Caption = 'Received Date';
        }
        field(9; "Received Lot No."; Code[50])
        {
            Caption = 'Received Lot No.';
        }
        field(10; "Purch. Order Status"; Option)
        {
            Caption = 'Purch. Order Status';
            Editable = false;
            OptionCaption = 'Open,Created,Posted';
            OptionMembers = Open,Created,Posted;
        }
        field(11; "Purch. Order No."; Code[20])
        {
            Caption = 'Purch. Order No.';
            Editable = false;
            FieldClass = Normal;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(12; "Purch. Order Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Purch. Order Line No.';
            Editable = false;
            FieldClass = Normal;
        }
        field(13; "Purch. Rcpt. No."; Code[20])
        {
            Caption = 'Purch. Rcpt. No.';
            Editable = false;
            TableRelation = "Purch. Rcpt. Header";
        }
        field(14; "Purch. Rcpt. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Purch. Rcpt. Line No.';
            Editable = false;
            TableRelation = "Purch. Rcpt. Line"."Line No." WHERE("Document No." = FIELD("Purch. Rcpt. No."));
        }
        field(15; "Hauler P.O. No."; Code[20])
        {
            Caption = 'Hauler P.O. No.';
            Editable = false;
            FieldClass = Normal;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(16; "Hauler P.O. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Hauler P.O. Line No.';
            Editable = false;
            FieldClass = Normal;
        }
        field(17; "Rejection Action"; Option)
        {
            Caption = 'Rejection Action';
            OptionCaption = ' ,Withhold Payment';
            OptionMembers = " ","Withhold Payment";

            trigger OnValidate()
            var
                CommManifestHeader: Record "EN Commdity Manifest Hdr ELA";
            begin
                if ("Rejection Action" > 0) then begin
                    CommManifestHeader.Get("Commodity Manifest No.");
                    CommManifestHeader.TestField("Product Rejected", true);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Commodity Manifest No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Manifest Quantity";
        }
        key(Key2; "Commodity Manifest No.", "Vendor No.", "Received Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        case "Purch. Order Status" of
            "Purch. Order Status"::Created:
                begin
                    CalcFields("Purch. Order No.");
                    DeletePurchOrderLine;
                end;
            "Purch. Order Status"::Posted:
                FieldError("Purch. Order Status");
        end;
    end;

    trigger OnInsert()
    begin
        TestField("Vendor No.");
    end;

    trigger OnModify()
    begin
        if ("Purch. Order Status" = "Purch. Order Status"::Posted) then
            FieldError("Purch. Order Status");
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800ItemTracking: Codeunit "Process 800 Item Tracking ELA";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        Text000: Label 'Do you want to assign a %1?';

    [Scope('Internal')]
    procedure AssistEditRcptLotNo(OldCommManifestLine: Record "EN Commodity Manifest Line ELA"): Boolean
    begin
        TestField("Vendor No.");
        if Confirm(Text000, false, FieldCaption("Received Lot No.")) then begin
            AssignRcptLotNo;
            exit(true);
        end;
    end;


    procedure AssignRcptLotNo()
    var
        CommManifestHeader: Record "EN Commdity Manifest Hdr ELA";
        Vendor: Record Vendor;
        InvtSetup: Record "Inventory Setup";
    begin

    end;

    [Scope('Internal')]
    procedure SetupNewLine(OldCommManifestLine: Record "EN Commodity Manifest Line ELA")
    var
        CommManifestHeader: Record "EN Commdity Manifest Hdr ELA";
    begin
        if CommManifestHeader.Get("Commodity Manifest No.") then
            "Received Date" := CommManifestHeader."Posting Date";
    end;


    procedure DeletePurchOrderLine()
    var
        PurchLine: Record "Purchase Line";
        PurchOrder: Record "Purchase Header";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
    begin
    end;

    [Scope('Internal')]
    procedure GetReceivedPercentage(): Decimal
    var
        CommManifestLine: Record "EN Commodity Manifest Line ELA";
        TotalQty: Decimal;
    begin

    end;
}

