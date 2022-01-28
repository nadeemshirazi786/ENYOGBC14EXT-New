/// <summary>
/// Page EN Container Assign Contents (ID 14229226).
/// </summary>
page 14229226 "Assign Container Contents ELA"
{

    ApplicationArea = Warehouse;
    Caption = 'Assign Container Contents';
    PageType = List;
    // SourceTable = "Purchase Line";
    SourceTable = "WMS Asgn Container Content ELA";
    SourceTableTemporary = true; //Must be set to temporary for this operation.
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = Warehouse;
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Warehouse;
                }
                field("Line No."; Rec."Line No.")
                {
                    Editable = false;
                    ApplicationArea = Warehouse;
                }
                field("Item No."; Rec."Item No.")
                {
                    Editable = false;
                    ApplicationArea = Warehouse;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ApplicationArea = Warehouse;
                }
                field("Document Qty."; "Document Qty.")
                {
                    Editable = false;
                    ApplicationArea = Warehouse;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure';
                    Editable = false;
                    ApplicationArea = Warehouse;
                }

                field("Qty. Outstanding"; Rec."Qty. Outstanding")
                {
                    Caption = 'Qty. Outstanding';
                    Editable = false;
                    ApplicationArea = Warehouse;
                }

                field("Qty. To Handle"; Rec."Qty. To Handle")
                {
                    Caption = 'Qty. To Handle';
                    QuickEntry = true;
                    ApplicationArea = Warehouse;
                    trigger OnValidate()
                    var
                    begin
                        UpdatePage();
                    end;
                }
                field("Qty. Per Container"; Rec."Qty. Per Container")
                {
                    Caption = 'Qty. Per Container';
                    QuickEntry = true;
                    ApplicationArea = Warehouse;
                    trigger OnValidate()
                    var
                    begin
                        UpdatePage();
                    end;
                }
                field("Total Containers"; Rec."Total Containers")
                {
                    Caption = 'Total Containers';
                    ApplicationArea = Warehouse;
                    Editable = false;
                }

                field("Qty. Remaining"; RemainingQty)
                {
                    // nee to check above formula.
                    Editable = false;
                    ApplicationArea = Warehouse;
                }

                field("Vendor Lot No."; Rec."Vendor Lot No.")
                {

                    ApplicationArea = Warehouse;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = Warehouse;
                }

                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }

                field("Activity No."; Rec."Activity No.")
                {
                    ApplicationArea = All;
                }

                field("Activity Line No."; "Activity Line No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Process)
            {

                action("Generate Containers")
                {
                    ApplicationArea = Suite;
                    Caption = 'Generate &Containers';
                    Image = CreateDocuments;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F6';
                    ToolTip = 'Generate Containers automatically';
                    Enabled = EnableAutoGenerate;
                    trigger OnAction()
                    var
                        ContMgmt: Codeunit "Container Mgmt. ELA";
                        WhseDocType: enum "Whse. Doc. Type ELA";
                    begin
                        //EN1.00 Bj Fix  to add Qty Per Container instead of Qty to Handle.
                        ContMgmt.GenarateContainerContents(
                            '', ENWMSSourceDocTypeFilter, "Document Type", Rec."Document No.", "Line No.", "Item No.",
                            "Unit of Measure Code", "Qty. Per Container", "Total Containers", "Vendor Lot No.", "Location Code",
                            WhseDocTypeFilter, WhseDocNoFilter, WhseActivityTypeFilter, WhseActivityNoFilter
                            );
                        /* ContMgmt.GenarateContainerContents(
                             '', ENWMSSourceDocTypeFilter, "Document Type", Rec."Document No.", "Line No.", "Item No.",
                             "Unit of Measure Code", "Qty. To Handle", "Total Containers", "Vendor Lot No.", "Location Code",
                             WhseDocTypeFilter, WhseDocNoFilter, WhseActivityTypeFilter, WhseActivityNoFilter
                             );*/

                        ContMgmt.ShowContainer(ENWMSSourceDocTypeFilter, '', "Location Code", "Document Type", "Document No.",
                          WhseDocType::Receipt, '', WhseActivityTypeFilter, WhseActivityNoFilter);
                    end;
                }
            }
        }
    }
    //"Net Weight" qty to receive
    // Total Containers "Units per Parcel"

    var
        RemainingQty: Decimal; // do we need to caclualte separately.
        DocumentTypeFilter: Option;
        DocumentNoFilter: code[20];
        DocumentLineNoFilter: Integer;
        WhseDocTypeFilter: Enum "Whse. Doc. Type ELA";
        WhseDocNoFilter: code[20];
        ContainerNoFilter: code[20];
        ENWMSSourceDocTypeFilter: enum "WMS Source Doc Type ELA";
        IsManualFilter: Boolean;
        WhseActivityTypeFilter: Enum "WMS Activity Type ELA";
        WhseActivityNoFilter: code[20];
        WhseActivityLineNoFilter: Integer;
        [InDataSet]
        EnableAutoGenerate: Boolean;

    /// <summary>
    /// OnOpenPage.
    /// </summary>
    trigger OnOpenPage()
    var
    begin
        LoadData();
        UpdatePage();
    end;


    trigger OnClosePage()
    var
    begin
        SaveData();
    end;

    /// <summary>
    /// LoadData.
    /// </summary>
    procedure LoadData()
    var
    begin
        if IsManualFilter then
            EnableAutoGenerate := false
        else
            EnableAutoGenerate := true;

        case ENWMSSourceDocTypeFilter of
            "WMS Source Doc Type ELA"::"Purchase Order":
                begin
                    PopulateFromPurchaseOrder();
                end;

            "WMS Source Doc Type ELA"::"Sales Order":
                begin
                    if WhseActivityNoFilter <> '' then
                        PopulateFromWhsePick()
                    else
                        PopulateFromSalesOrder();
                end;
        end;
    end;


    /// <summary>
    /// SetDocumentFilters.
    /// </summary>
    /// <param name="ENWMSSourceDocType">enum "EN WMS Source Doc Type".</param>
    /// <param name="DocumentType">Option.</param>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="DocumentLineNo">Integer.</param>
    /// <param name="WhseDocType">Enum "EN Whse. Doc. Type".</param>
    /// <param name="WhseDocNo">code[20].</param>
    /// <param name="WhseActType">Enum "EN WMS Activity Type".</param>
    /// <param name="WhseActNo">code[20].</param>
    /// <param name="ContainerNo">code[20].</param>
    /// <param name="IsManual">Boolean.</param>
    procedure SetDocumentFilters(
        ENWMSSourceDocType: enum "WMS Source Doc Type ELA";
        DocumentType: Option;
        DocumentNo: Code[20];
        DocumentLineNo: Integer;
        WhseDocType: Enum "Whse. Doc. Type ELA";
        WhseDocNo: code[20];
        WhseActType: Enum "WMS Activity Type ELA";
        WhseActNo: code[20];
        WhseActLineNo: Integer;
        ContainerNo: code[20];
        IsManual: Boolean)
    var
    begin
        ENWMSSourceDocTypeFilter := ENWMSSourceDocType;
        DocumentTypeFilter := DocumentType;
        DocumentNoFilter := DocumentNo;
        WhseDocTypeFilter := WhseDocType;
        WhseDocNoFilter := WhseDocNo;
        DocumentLineNoFilter := DocumentLineNo;
        WhseActivityTypeFilter := WhseActType;
        WhseActivityNoFilter := WhseActNo;
        IsManualFilter := IsManual;
        ContainerNoFilter := ContainerNo;
    end;

    /// <summary>
    /// UpdatePage.
    /// </summary>
    local procedure UpdatePage()
    begin
        if "Qty. Per Container" <> 0 then
            "Total Containers" := "Qty. To Handle" / "Qty. Per Container";

        RemainingQty := "Qty. Outstanding" - "Qty. To Handle";
    end;

    local procedure SaveData()
    var
        ContainerContent: record "Container Content ELA";
        ContMgt: Codeunit "Container Mgmt. ELA";
    begin
        if IsManualFilter then begin
            ContMgt.AddContentToContainer(ContainerNoFilter, "Item No.", "Unit of Measure Code", "Qty. To Handle", "Vendor Lot No.",
            "Document No.", "Line No.", WhseDocTypeFilter, WhseDocNoFilter, WhseActivityTypeFilter, "Activity No.", "Activity Line No."
            );
        end;
    end;

    local procedure PopulateFromSalesOrder()
    var
        SalesLine: Record "Sales Line";
        WhseRcptLine: record "Warehouse Receipt Line";
        WhseShipLine: record "Warehouse Shipment Line";
        ItemUnitOfMeasure: record "Item Unit of Measure";
        ENWMSUtil: Codeunit "WMS Util ELA";
        BulkUOM: code[10];
        QtyPerBaseUOM: Decimal;
        QtyOnContainers: Decimal;
        WMSSalesDocType: enum "WMS Sales Document Type ELA";
    begin
        SalesLine.reset;
        SalesLine.SetRange("Document Type", DocumentTypeFilter);
        SalesLine.SetRange("Document No.", DocumentNoFilter);
        // if IsManualFilter then
        if DocumentLineNoFilter <> 0 then
            SalesLine.SetRange("Line No.", DocumentLineNoFilter);
        if SalesLine.FindSet() then
            repeat
                Init();
                "Document Type" := WMSSalesDocType::Order;
                //SalesLine."Document Type";
                "Document No." := SalesLine."Document No.";
                "Line No." := SalesLine."Line No.";
                Insert();
                if SalesLine.Type = SalesLine.Type::Item then begin
                    // Type := SalesLine.Type;
                    "Item No." := SalesLine."No.";
                    "Location Code" := SalesLine."Location Code";
                    Description := SalesLine.Description;
                    "Unit of Measure Code" := SalesLine."Unit of Measure Code";
                    "Document Qty." := SalesLine.Quantity;
                    // "Quantity (Base)" := PurchLine."Quantity (Base)";
                    QtyOnContainers := ContMgmt.GetQtyFromContainers(ENWMSSourceDocTypeFilter, "Document Type",
                         "Document No.", WhseDocTypeFilter, WhseDocNoFilter, WhseActivityTypeFilter, WhseActivityNoFilter,
                         SalesLine."No.", SalesLine."Unit of Measure Code");
                    Validate("Qty. To Handle", SalesLine."Outstanding Quantity" - QtyOnContainers); // Qty TO Rec/ OS Qty
                    validate("Qty. Outstanding", SalesLine."Outstanding Quantity");
                    ENWMSUtil.GetItemBulkUOMDetail(SalesLine."No.", BulkUOM, QtyPerBaseUOM);
                    validate("Qty. Per Container", QtyPerBaseUOM); //"Qty. Per Container"
                    if "Qty. Per Container" = 0 then
                        "Qty. Per Container" := 1;
                    "Total Containers" := "Qty. To Handle" / "Qty. Per Container";
                    RemainingQty := "Qty. Outstanding" - "Qty. To Handle";
                    Modify();
                end;
            until SalesLine.Next() = 0;
    end;

    local procedure PopulateFromPurchaseOrder()
    var
        PurchLine: Record "Purchase Line";
        WhseRcptLine: record "Warehouse Receipt Line";
        WhseShipLine: record "Warehouse Shipment Line";
        ItemUnitOfMeasure: record "Item Unit of Measure";
        ENWMSUtil: Codeunit "WMS Util ELA";
        BulkUOM: code[10];
        QtyPerBaseUOM: Decimal;
        QtyOnContainers: Decimal;
        WMSSalesDocType: enum "WMS Sales Document Type ELA";
    begin
        PurchLine.reset;
        PurchLine.SetRange("Document Type", DocumentTypeFilter);
        PurchLine.SetRange("Document No.", DocumentNoFilter);
        // if IsManualFilter then
        if DocumentLineNoFilter <> 0 then
            PurchLine.SetRange("Line No.", DocumentLineNoFilter);
        if PurchLine.FindSet() then
            repeat
                Init();
                "Document Type" := WMSSalesDocType::Order;
                "Document No." := PurchLine."Document No.";
                "Line No." := PurchLine."Line No.";
                Insert();
                if PurchLine.Type = PurchLine.Type::Item then begin
                    // Type := PurchLine.Type;
                    "Item No." := PurchLine."No.";
                    "Location Code" := PurchLine."Location Code";
                    Description := PurchLine.Description;
                    "Unit of Measure Code" := PurchLine."Unit of Measure Code";
                    "Document Qty." := PurchLine.Quantity;
                    // "Quantity (Base)" := PurchLine."Quantity (Base)";
                    QtyOnContainers := ContMgmt.GetQtyFromContainers(ENWMSSourceDocTypeFilter, "Document Type",
                         "Document No.", WhseDocTypeFilter, WhseDocNoFilter, WhseActivityTypeFilter, WhseActivityNoFilter,
                         PurchLine."No.", PurchLine."Unit of Measure Code");
                    Validate("Qty. To Handle", PurchLine."Outstanding Quantity" - QtyOnContainers); // Qty TO Rec/ OS Qty
                    validate("Qty. Outstanding", PurchLine."Outstanding Quantity");
                    ENWMSUtil.GetItemBulkUOMDetail(PurchLine."No.", BulkUOM, QtyPerBaseUOM);
                    validate("Qty. Per Container", QtyPerBaseUOM); //"Qty. Per Container"
                    "Vendor Lot No." := PurchLine."Vendor Lot No. ELA";
                    "Vendor Item No." := PurchLine."Vendor Item No.";
                    if "Qty. Per Container" = 0 then
                        "Qty. Per Container" := 1;
                    "Total Containers" := "Qty. To Handle" / "Qty. Per Container";
                    RemainingQty := "Qty. Outstanding" - "Qty. To Handle";
                    Modify();
                end;
            until PurchLine.Next() = 0;
    end;


    local procedure PopulateFromWhsePick()
    var
        WhseRcptLine: record "Warehouse Receipt Line";
        WhseShipLine: record "Warehouse Shipment Line";
        WhseActLine: record "Warehouse Activity Line";
        ItemUnitOfMeasure: record "Item Unit of Measure";
        ENWMSUtil: Codeunit "WMS Util ELA";
        BulkUOM: code[10];
        QtyPerBaseUOM: Decimal;
        QtyOnContainers: Decimal;
        WMSSalesDocType: enum "WMS Sales Document Type ELA";
    begin
        WhseActLine.reset;
        WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
        WhseActLine.SetRange("No.", WhseActivityNoFilter);
        if WhseActLine.FindSet() then
            repeat
                Init();
                "Document Type" := WMSSalesDocType::Order;
                "Document No." := WhseActLine."Source No.";
                "Line No." := WhseActLine."Source Line No.";
                Insert();
                "Item No." := WhseActLine."Item No.";
                "Location Code" := WhseActLine."Location Code";
                Description := WhseActLine.Description;
                "Unit of Measure Code" := WhseActLine."Unit of Measure Code";
                "Document Qty." := WhseActLine.Quantity;
                // "Quantity (Base)" := PurchLine."Quantity (Base)";
                QtyOnContainers := ContMgmt.GetQtyFromContainers(ENWMSSourceDocTypeFilter, "Document Type", "Document No.",
                    WhseDocTypeFilter, WhseDocNoFilter, WhseActivityTypeFilter, WhseActivityNoFilter,
                     WhseActLine."Item No.", WhseActLine."Unit of Measure Code");

                Validate("Qty. To Handle", WhseActLine."Qty. Outstanding" - QtyOnContainers); // Qty TO Rec/ OS Qty
                validate("Qty. Outstanding", WhseActLine."Qty. Outstanding");
                ENWMSUtil.GetItemBulkUOMDetail(WhseActLine."Item No.", BulkUOM, QtyPerBaseUOM);
                validate("Qty. Per Container", QtyPerBaseUOM); //"Qty. Per Container"
                if "Qty. Per Container" = 0 then
                    "Qty. Per Container" := 1;
                "Total Containers" := "Qty. To Handle" / "Qty. Per Container";
                RemainingQty := "Qty. Outstanding" - "Qty. To Handle";
                "Activity No." := WhseActLine."No.";
                "Activity Line No." := WhseActLine."Line No.";
                Modify();
            until WhseActLine.Next() = 0;
    end;

    var
        ContMgmt: codeunit "Container Mgmt. ELA";

}


