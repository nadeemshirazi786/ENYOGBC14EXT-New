tableextension 14229635 "EN LT WhseShpmtLine EXT ELA" extends "Warehouse Shipment Line"
{
    fields
    {
        modify(Quantity)
        {
            trigger OnBeforeValidate()
            begin
                // IF NOT gblnAllowZeroQty THEN
                IF gblnBypassStatusCheck THEN
                    EXIT;
            end;
        }
		field(14229200; "Assigned App. Role ELA"; code[20])
        {
            Caption = 'Assigned Role';
            DataClassification = ToBeClassified;
        }

        field(14229201; "Assigned To ELA"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(14229220; "Ship Action ELA"; Enum "WMS Ship Acion ELA")
        {
            Caption = 'Ship Action';
            // OptionCaption = ' ,Fullfill,Cut,Over Ship,Back Order';
            // OptionMembers = " ",Fullfill,Cut,"Over Ship","Back Order";
            DataClassification = ToBeClassified;
        }

        field(14229221; "Source Order No. ELA"; COde[20])
        {
            DataClassification = ToBeClassified;
        }

        field(14229222; "Source Ship-to ELA"; Code[10])
        {
            Caption = 'Source Ship-to';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229223; "Source Ship-to Name ELA"; Text[100])
        {
            Caption = 'Source Ship-to Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229224; "Source Ship-to Name 2 ELA"; Text[50])
        {
            Caption = 'Source Ship-to Name 2';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229225; "Source Address ELA"; Text[100])
        {
            Caption = 'Source Address';
            DataClassification = ToBeClassified;
        }

        field(14229226; "Source Address 2 ELA"; Text[50])
        {
            Caption = 'Source Address 2';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229227; "Source Ship-to City ELA"; Text[30])
        {
            Caption = 'Source Ship-to City';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229228; "Source Ship-to Contact ELA"; Text[100])
        {
            Caption = 'Source Ship-to Contact';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229229; "Source Ship-to Post Code ELA"; Code[20])
        {
            Caption = 'Source Ship-to Post Code';
            // TableRelation = IF ("Source Ship-to Country" = CONST()) "Post Code"
            // ELSE
            // IF ("Source Ship-to Country" = FILTER(<> '')) "Post Code"
            //  WHERE("Source Ship-to Country" = FIELD("Source Ship-to Country"))
            // TableRelation = if ("Source Ship-to Country" = const()) "Post Code" 
            // else
            // if ("Source Ship-to Country" = filter(<>'')) "Post Code"
            // where ("Cout")
            // ValidateTableRelation = false;
            // TestTableRelation = false;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229230; "Source Ship-to County ELA"; Text[30])
        {
            Caption = 'Source Ship-to County';
            // CaptionClass = '5,1,' + "Ship-to Country/Region Code";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229231; "Source Ship-to Country ELA"; Code[10])
        {
            Caption = 'Source Ship-to Country';
            TableRelation = "Country/Region";
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229232; "Orig. Ordered Qty. ELA"; Decimal)
        {

        }

        field(14229233; "Orig. Asked Qty. ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229234; "Last Modified Qty. ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229235; "Qty. to Handle ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229236; "Qty. to Handle (Base) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229237; "Cut/Overship Qty. ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229238; "Trip No. ELA"; code[20])
        {
            TableRelation = "Trip Load ELA" where(Direction = const(Outbound));
        }

        field(14229239; "Release to QC ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            /*trigger OnValidate()
            var
                ShipMgmt: Codeunit "Shipment Mgmt. ELA";
            begin
                TestField("Qty. Picked");
                ShipMgmt.UpdateShipmentDashReleaseQC(rec);
            end;*/
        }
        field(14229240; "QC Completed ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            /*trigger OnValidate()
            var
                ShipMgmt: Codeunit "Shipment Mgmt. ELA";
            begin
                TestField("Release to QC ELA", true);
                ShipMgmt.UpdateShipmentDashQCComplete(rec);
            end;*/
        }
        field(14229241; "Assigned QC User ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            /*trigger OnValidate()
            var
                ShipMgmt: Codeunit "Shipment Mgmt. ELA";
            begin
                // TestField("Release to QC ELA", true);
                ShipMgmt.UpdateShipmentDashAssignedToQC(rec);
            end;*/
        }
    }
    procedure SetLotQuantity(LotNo: Code[20])
    begin
        GetSourceDocumentLine(SalesLine, PurchLine, TransLine);
        UpdateLotQuantity(SalesLine, PurchLine, TransLine);

    end;

    local procedure GetSourceDocumentLine(VAR SalesLine: Record "Sales Line"; VAR PurchaseLine: Record "Purchase Line"; VAR TransferLine: Record "Transfer Line")
    begin
        CASE "Source Type" OF
            DATABASE::"Sales Line":
                SalesLine.GET("Source Subtype", "Source No.", "Source Line No.");
            DATABASE::"Purchase Line":
                PurchaseLine.GET("Source Subtype", "Source No.", "Source Line No.");
            DATABASE::"Transfer Line":
                TransferLine.GET("Source No.", "Source Line No.");
        END;

    end;

    local procedure UpdateLotQuantity(VAR SalesLine: Record "Sales Line"; VAR PurchaseLine: Record "Purchase Line"; VAR TransferLine: Record "Transfer Line")
    begin
        CASE "Source Type" OF
            DATABASE::"Sales Line":
                BEGIN
                    SalesLine.MODIFY(TRUE);
                    SalesLine.WarehouseLineQuantity("Qty. to Ship (Base)", QtyToShipAlt, SalesLine."Qty. to Invoice (Base)"); // P80077569
                    SalesLine.UpdateLotTracking(TRUE, 0);
                END;
            DATABASE::"Purchase Line":
                BEGIN
                    PurchaseLine.MODIFY(TRUE);
                    PurchaseLine.WarehouseLineQuantityELA("Qty. to Ship (Base)", QtyToShipAlt, PurchaseLine."Qty. to Invoice (Base)"); // P80077569
                    PurchaseLine.UpdateLotTracking(TRUE);
                END;
            DATABASE::"Transfer Line":
                BEGIN
                    TransferLine.MODIFY(TRUE);
                    TransferLine.UpdateLotTracking(TRUE, 0);
                END;
        END;
    end;

    procedure GetLotNo(): code[50]
    begin
        CASE "Source Type" OF
            DATABASE::"Sales Line":
                BEGIN
                    SalesLine.GET("Source Subtype", "Source No.", "Source Line No.");
                    SalesLine.GetLotNo;
                    EXIT(SalesLine."Lot No. ELA");
                END;
            DATABASE::"Purchase Line":
                BEGIN
                    PurchLine.GET("Source Subtype", "Source No.", "Source Line No.");
                    PurchLine.GetLotNo;
                    EXIT(PurchLine."Supplier Lot No. ELA");
                END;
            DATABASE::"Transfer Line":
                BEGIN
                    TransLine.GET("Source No.", "Source Line No.");
                    TransLine.GetLotNo;
                    EXIT(TransLine."Lot No. ELA");
                END;
        END;

    end;

    procedure AllowZeroQuantity(pblnAllowZeroQty: Boolean)
    begin
        gblnAllowZeroQty := pblnAllowZeroQty;
    end;

    procedure BypassStatusCheck(pblnBypassStatusCheck: Boolean)
    begin
        gblnBypassStatusCheck := pblnBypassStatusCheck;
    end;

    procedure jfFromWhsePost(pblnFromWhsePost: Boolean)
    begin
        gblnFromWhsePost := pblnFromWhsePost;
    end;

    procedure BypassBooleanTestRelease(): Boolean
    begin
        exit(true);
    end;

    var
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        SalesLine: Record "Sales Line";
        QtyToShipAlt: Decimal;
        gblnAllowZeroQty: Boolean;
        gblnBypassStatusCheck: Boolean;
        gblnFromWhsePost: Boolean;
		UpdateSource: Option " ",Shipment,"Task Queue",Activity,ShipBoard;
        ActivityType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";

}