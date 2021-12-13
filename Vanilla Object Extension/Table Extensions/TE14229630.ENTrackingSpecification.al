tableextension 14229630 "EN LT TrackingSpecf. EXT ELA" extends "Tracking Specification"
{
    fields
    {
        modify("Expiration Date")
        {
            trigger OnAfterValidate()
            var
                ldteMinExpiryDate: Date;
            begin
                IF "Expiration Date" <= Today then
                    ERROR('You cannot enter past date', "Lot No.", "Expiration Date");
                jfCalcExpirationWarning;

                IF jfCalcShelfLife(ldteMinExpiryDate) THEN BEGIN
                    IF "Expiration Date" < ldteMinExpiryDate then
                        IF Confirm(gText001, false, "Lot No.", ldteMinExpiryDate) then begin

                        end else begin
                            "Expiration Date" := 0D;
                            Rec.Modify(true);
                        end;
                END;

            end;
        }
        modify("Quantity (Base)")
        {
            trigger OnAfterValidate()
            var
                lcduSecUOMMgt: Codeunit "EN UOM Management";
                ldecQtyToPass: Decimal;
                lcodItemUOM: Code[10];
            begin

                //Check UOM to see if variable

                IF ("Quantity (Source UOM) ELA" <> 0) AND (CheckVariableUOM) THEN BEGIN
                    "Qty. per Unit of Measure" := ROUND("Quantity (Base)" / "Quantity (Source UOM) ELA", 0.00001);
                    GetSourceUOM(Rec, ldecQtyToPass, lcodItemUOM);
                    lcduSecUOMMgt.CheckVariableUOMTolerance("Item No.", lcodItemUOM, "Qty. per Unit of Measure", TRUE);

                END ELSE BEGIN
                    IF "Qty. per Unit of Measure" <> 0 THEN
                        "Quantity (Source UOM) ELA" := ROUND("Quantity (Base)" / "Qty. per Unit of Measure", 0.00001);
                END;

            end;
        }
        field(14229400; "Net Weight ELA"; Decimal)
        {
            Caption = 'Net Weight';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if ("Net Weight ELA" * "Net Weight Handled ELA" < 0) or
                  (Abs("Net Weight ELA") < Abs("Net Weight Handled ELA")) then
                    FieldError("Net Weight ELA", StrSubstNo(Text002, FieldCaption("Net Weight Handled ELA")));

                InitNWToShip;

            end;
        }
        field(14229401; "Net Weight Handled ELA"; Decimal)
        {
            Caption = 'Net Weight Handled';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229402; "Net Weight to Handle ELA"; Decimal)
        {
            Caption = 'Net Weight to Handle';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if ("Net Weight Handled ELA" * "Net Weight ELA" < 0) or
                  (Abs("Net Weight to Handle ELA") > Abs("Net Weight ELA") - "Net Weight Handled ELA") then
                    Error(
                      Text001,
                      "Net Weight ELA" - "Net Weight Handled ELA");


                InitNWToInvoice;

            end;
        }
        field(14229403; "Net Weight to Invoice ELA"; Decimal)
        {
            Caption = 'Net Weight to Invoice';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if ("Net Weight Invoiced ELA" * "Net Weight ELA" < 0) or
                  (Abs("Net Weight to Invoice ELA") > Abs("Net Weight to Handle ELA" + "Net Weight Handled ELA" - "Net Weight Invoiced ELA")) then
                    Error(
                      Text000,
                      "Net Weight to Handle ELA" + "Net Weight Handled ELA" - "Net Weight Invoiced ELA");


            end;
        }
        field(14229404; "Net Weight Invoiced ELA"; Decimal)
        {
            Caption = 'Net Weight Invoiced';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229405; "Lot Blocked ELA"; Boolean)
        {
            Caption = 'Lot Blocked';
            CalcFormula = Lookup("Lot No. Information".Blocked WHERE("Item No." = FIELD("Item No."),
                                                                      "Lot No." = FIELD("Lot No.")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14229150; "Supplier Lot No. ELA"; Code[50])
        {
            Caption = 'Supplier Lot No.';
            DataClassification = ToBeClassified;
        }
        field(14229151; "Lot Creation Date ELA"; Date)
        {
            Caption = 'Lot Creation Date';
            DataClassification = ToBeClassified;
        }
        field(14229152; "Country/Regn of Orign Code ELA"; Code[20])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        field(14229153; "New Lot Status Code ELA"; Code[20])
        {
            Caption = 'New Lot Status Code';
            DataClassification = ToBeClassified;
        }
        field(14229154; "Phys. Inventory ELA"; Boolean)
        {
            Caption = 'Phys. Inventory';
            DataClassification = ToBeClassified;
        }
        field(14229155; "Quantity (Alt.) ELA"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = ToBeClassified;
            CaptionClass = STRSUBSTNO('37002080,0,0,%1', "Item No.");
            Editable = false;
        }
        field(14229156; "Qty. to Handle (Alt.) ELA"; Decimal)
        {
            Caption = 'Qty. to Handle (Alt.)';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ItemJnlLine: Record "Item Journal Line";
                AltQtyTransNo: Integer;
            begin
                // PR3.60
                AltQtyMgmt.TestTrackingAltQtyInfoELA(Rec, FALSE);

                Item.GET("Item No.");
                IF (CurrFieldNo = FIELDNO("Qty. to Handle (Alt.) ELA")) THEN BEGIN
                    Item.TESTFIELD("Catch Alternate Qtys. ELA", TRUE);
                    //TESTFIELD("Qty. to Handle (Base)"); // PR3.61
                    // P8000538A
                    IF ("Source Type" <> DATABASE::"Item Journal Line") OR
                      (NOT ("Source Subtype" IN [ItemJnlLine."Entry Type"::"Positive Adjmt.", ItemJnlLine."Entry Type"::"Negative Adjmt."]))
                    THEN
                        TESTFIELD("Qty. to Handle (Alt.) ELA");
                    // P8000538A
                    CheckSourceDocumentStatusELA; // P80070336
                    AltQtyTransNo := AltQtyMgmt.GetSourceAltQtyTransNoELA("Source Type", DocumentTypeELA, DocumentNoELA,
                      TemplateNameELA, BatchNameELA, "Source Ref. No.", FALSE);
                    AltQtyMgmt.CheckSummaryTolerance2ELA(AltQtyTransNo, "Item No.",
                      "Serial No.", "Lot No.", FIELDCAPTION("Qty. to Handle (Alt.) ELA"),
                      "Qty. to Handle (Base)", "Qty. to Handle (Alt.) ELA");
                END;
                AltQtyMgmt.SetTrackingLineAltQtyELA(Rec);
                // PR3.60
            end;

        }
        field(14229157; "Quantity Handled (Alt.) ELA"; Decimal)
        {
            Caption = 'Quantity Handled (Alt.)';
            DataClassification = ToBeClassified;
            CaptionClass = STRSUBSTNO('37002080,0,15,%1', "Item No.");
            Editable = false;
        }
        field(14229158; "Qty. to Invoice (Alt.) ELA"; Decimal)
        {
            Caption = 'Qty. to Invoice (Alt.)';
            DataClassification = ToBeClassified;
        }
        field(14229159; "Quantity Invoiced (Alt.) ELA"; Decimal)
        {
            Caption = 'Quantity Invoiced (Alt.)';
            DataClassification = ToBeClassified;
        }
        field(14229160; "Qty. (Alt.) (Calculated) ELA"; Decimal)
        {
            Caption = 'Qty. (Alt.) (Calculated)';
            DataClassification = ToBeClassified;
        }
        field(14229161; "Qty. (Alt.) (Phys. Invt.) ELA"; Decimal)
        {
            Caption = 'Qty. (Alt.) (Phys. Invt.)';
            DataClassification = ToBeClassified;
        }
        field(14229162; "Qty. (Phys. Inventory) ELA"; Decimal)
        {
            Caption = 'Qty. (Phys. Inventory)';
            MinValue = 0;
            DataClassification = ToBeClassified;
        }
        field(14229163; "Qty. (Calculated) ELA"; Decimal)
        {
            Caption = 'Qty. (Calculated)';
            DataClassification = ToBeClassified;
        }
        field(14229164; "Quantity (Source UOM) ELA"; Decimal)
        {
            Caption = 'Quantity (Source UOM)';
            DecimalPlaces = 0 : 15;
            trigger OnValidate()
            var
                lcduSecUOMMgt: codeunit "EN UOM Management";
                ldecQtyToPass: Decimal;
                lcodItemUOM: Code[10];
            begin

                IF ("Quantity (Source UOM) ELA" <> 0) AND (CheckVariableUOM) THEN BEGIN
                    IF "Quantity (Base)" = 0 THEN BEGIN
                        VALIDATE("Quantity (Base)", ROUND("Quantity (Source UOM) ELA" * "Qty. per Unit of Measure", 0.00001));
                    END ELSE BEGIN
                        IF CONFIRM(gText002, TRUE, FIELDCAPTION("Qty. per Unit of Measure")) THEN BEGIN
                            "Qty. per Unit of Measure" := ROUND("Quantity (Base)" / "Quantity (Source UOM) ELA", 0.00001);

                            GetSourceUOM(Rec, ldecQtyToPass, lcodItemUOM);
                            lcduSecUOMMgt.CheckVariableUOMTolerance("Item No.", lcodItemUOM, "Qty. per Unit of Measure", TRUE);

                            VALIDATE("Quantity (Base)");
                        END ELSE BEGIN
                            VALIDATE("Quantity (Base)", ROUND("Quantity (Source UOM) ELA" * "Qty. per Unit of Measure", 0.00001));
                        END;
                    END;
                END ELSE BEGIN
                    VALIDATE("Quantity (Base)", ROUND("Quantity (Source UOM) ELA" * "Qty. per Unit of Measure", 0.00001));
                END;
            end;

        }
    }
    var
        Text000: Label 'You cannot invoice more than %1 units.';
        Text001: Label 'You cannot handle more than %1 units.';
        Text002: Label 'must not be less than %1';


    procedure InitNWToShip()
    begin

        "Net Weight to Handle ELA" := "Net Weight ELA" - "Net Weight Handled ELA";

        InitNWToInvoice;

    end;


    procedure InitNWToInvoice()
    begin

        "Net Weight to Invoice ELA" := "Net Weight Handled ELA" + "Net Weight to Handle ELA" - "Net Weight Invoiced ELA";

    end;

    procedure TrackAlternateUnitsELA(): Boolean
    begin
        IF NOT Item.GET("Item No.") THEN
            EXIT(FALSE);
        EXIT(Item.TrackAlternateUnits);
    end;

    procedure CatchAlternateQtysELA(): Boolean
    begin
        IF NOT Item.GET("Item No.") THEN
            EXIT(FALSE);
        EXIT(Item."Catch Alternate Qtys. ELA");
    end;

    procedure CheckContainerQtyELA(QtyBase: Decimal): Boolean
    var
        ProcessFns: Codeunit "Process 800 Functions ELA";
    begin
        IF NOT ProcessFns.ContainerTrackingInstalled THEN
            EXIT(TRUE);
    end;

    procedure CheckSourceDocumentStatusELA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        IF NOT StatusCheckSuspended THEN
            CASE "Source Type" OF
                DATABASE::"Sales Line":
                    BEGIN
                        SalesLine.GET(DocumentTypeELA, DocumentNoELA, "Source Ref. No.");

                    END;
                DATABASE::"Purchase Line":
                    BEGIN
                        PurchaseLine.GET(DocumentTypeELA, DocumentNoELA, "Source Ref. No.");
                        IF PurchaseLine.CostInAlternateUnitsELA THEN BEGIN
                            PurchaseHeader.GET(DocumentTypeELA, DocumentNoELA);
                            PurchaseHeader.TESTFIELD(Status, PurchaseHeader.Status::Open);
                        END;
                    END;
            END;
    end;

    procedure SuspendStatusCheckELA(SuspendCheck: Boolean) WasSuspended: Boolean
    begin
        WasSuspended := StatusCheckSuspended; // P8006787
        StatusCheckSuspended := SuspendCheck;
    end;

    procedure DocumentTypeELA(): Integer
    begin
        IF "Source Type" IN [DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Transfer Line"] THEN // PR3.61
            EXIT("Source Subtype");
    end;

    procedure DocumentNoELA(): Code[20]
    begin
        IF "Source Type" IN [DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Transfer Line"] THEN // PR3.61
            EXIT("Source ID");
    end;

    procedure TemplateNameELA(): Code[10]
    begin
        IF "Source Type" IN [DATABASE::"Item Journal Line"] THEN
            EXIT("Source ID");
    end;

    procedure BatchNameELA(): Code[10]
    begin
        IF "Source Type" IN [DATABASE::"Item Journal Line"] THEN
            EXIT("Source Batch Name");
    end;

    procedure TestAltQtyEntryELA()
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        CASE "Source Type" OF
            DATABASE::"Sales Line":
                BEGIN
                    SalesLine.GET("Source Subtype", "Source ID", "Source Ref. No.");
                    //      SalesLine.TestAltQtyEntry;
                END;
            DATABASE::"Purchase Line":
                BEGIN
                    PurchLine.GET("Source Subtype", "Source ID", "Source Ref. No.");
                    PurchLine.TestAltQtyEntryELA;
                END;
            DATABASE::"Transfer Line":
                BEGIN
                    TransLine.GET("Source ID", "Source Ref. No.");
                    // TransLine.TestAltQtyEntry("Source Subtype");
                END;
        END;
    end;

    procedure jfCalcExpirationWarning()
    var
        lrecInvSetup: Record "Inventory Setup";
        lrecItem: Record Item;
        ldteMinRecvDate: Date;
    begin
        IF ("Lot No." = '') OR ("Expiration Date" = 0D) THEN
            EXIT;

        IF NOT ("Source Type" IN [DATABASE::"Purchase Line", DATABASE::"Prod. Order Line"]) THEN
            EXIT;

        IF NOT lrecItem.GET("Item No.") THEN
            EXIT;

        IF FORMAT(lrecItem."Expiration Warning") = '' THEN
            EXIT;

        ldteMinRecvDate := CALCDATE(lrecItem."Expiration Warning", "Expiration Date");

    end;

    procedure jfCalcShelfLife(VAR pdteMinExpiryDate: Date): Boolean
    var
        lrecInvSetup: Record "Inventory Setup";
        lrecItem: Record Item;
        lrecSalesLine: Record "Sales Line";
        lrecCustomer: Record Customer;
        //lrecItemCustomer: Record "Item Customer";
        ldteMinExpirationDate: Date;
        lrecPurchLine: Record "Purchase Line";
        lrecVendor: Record Vendor;
        lrecItemVendor: Record "Item Vendor";
    begin
        IF NOT ("Source Type" IN [DATABASE::"Sales Line", DATABASE::"Purchase Line"]) THEN
            EXIT;

        IF NOT lrecItem.GET("Item No.") THEN
            EXIT;

        IF "Source Subtype" IN [0, 1, 2] THEN BEGIN
            CASE "Source Type" OF
                DATABASE::"Purchase Line":
                    BEGIN
                        lrecPurchLine.GET("Source Subtype", "Source ID", "Source Ref. No.");

                        lrecVendor.GET(lrecPurchLine."Buy-from Vendor No.");
                        IF lrecItemVendor.GET(lrecPurchLine."Buy-from Vendor No.", "Item No.", "Variant Code") THEN;

                        IF FORMAT(lrecItemVendor."Shelf Life Requirement") = '' THEN
                            lrecItemVendor."Shelf Life Requirement" := lrecVendor."Shelf Life Requirement";

                        IF FORMAT(lrecItemVendor."Shelf Life Requirement") = '' THEN
                            lrecItemVendor."Shelf Life Requirement" := lrecItem."Shelf Life Requirement";

                        //Exit before the error (no error if no shelf life requirement)
                        IF FORMAT(lrecItemVendor."Shelf Life Requirement") = '' THEN
                            EXIT;


                        ldteMinExpirationDate := CALCDATE(lrecItemVendor."Shelf Life Requirement",
                                                          lrecPurchLine."Planned Receipt Date");

                        pdteMinExpiryDate := ldteMinExpirationDate;
                        IF "Expiration Date" <> 0D THEN
                            EXIT(ldteMinExpirationDate > "Expiration Date");

                    END;
            END;
        END;
    end;

    procedure CheckVariableUOM(): Boolean
    var
        lcodItemUOM: Code[10];
        lrecItemUOM: Record "Item Unit of Measure";
        ldecQtyToPass: Decimal;

    begin

        GetSourceUOM(Rec, ldecQtyToPass, lcodItemUOM);
        IF NOT lrecItemUOM.GET("Item No.", lcodItemUOM) THEN
            EXIT(FALSE);

        EXIT(lrecItemUOM."Allow Variable Qty. Per ELA");
    end;

    procedure GetSourceUOM(precTrackingSpec: Record "Tracking Specification"; VAR pdecSourceQty: Decimal; VAR pcodSourceUOM: Code[10])
    var
        lrecReservEntry: Record "Reservation Entry";
        lcduSecUOMMgt: codeunit "EN UOM Management";
    begin

        WITH precTrackingSpec DO BEGIN
            lrecReservEntry."Source Type" := "Source Type";
            lrecReservEntry."Source Subtype" := "Source Subtype";
            lrecReservEntry."Source ID" := "Source ID";
            lrecReservEntry."Source Batch Name" := "Source Batch Name";
            lrecReservEntry."Source Prod. Order Line" := "Source Prod. Order Line";
            lrecReservEntry."Source Ref. No." := "Source Ref. No.";

            lcduSecUOMMgt.GetSourceRecordUOM(lrecReservEntry, pdecSourceQty, pcodSourceUOM);

        END;
    end;

    var
        InvSetup: Record "Inventory Setup";
        Text37002004: TextConst ENU = 'may not be changed from %1';
        Text37002005: TextConst ENU = 'may not be changed to %1';
        AltQtyMgmt: Codeunit "Alt. Qty. Management ELA";
        Item: Record Item;
        StatusCheckSuspended: Boolean;
        gText001: TextConst ENU = 'Lot %1 does not meet the minimum shelf life requirements. Expiration must be %2 or later. \ Would you like to continue?';
        gText002: Label 'Do you want to update the %1?';
}

