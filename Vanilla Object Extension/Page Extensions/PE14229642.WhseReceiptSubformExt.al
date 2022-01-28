pageextension 14229642 "Whse. Receipt Subform" extends "Whse. Receipt Subform"
{
    layout
    {
        addafter("Qty. Received")
        {
            field("Receiving UOM ELA"; "Receiving UOM ELA")
            {
                Caption = 'Receiving Unit of Measure';
            }
            field("Tracking Status ELA"; txtTrackingStatus)
            {
                Caption = 'Tracking Status';
            }
            field("UOM Size Code"; isGetUOMSizeCode)
            {
                Caption = 'UOM Size Code';
            }
        }
		addafter("Qty. per Unit of Measure")
        {
            field("Line No."; "Line No.")
            {
                ApplicationArea = All;
            }
            field("Received By"; "Received By ELA")
            {
                ApplicationArea = All;
            }
            field("No. of Pallets ELA"; "No. of Pallets ELA")
            {
                ApplicationArea = ALL;
            }
        }

    }
	actions
    {
        addfirst(Processing)
        {
            action("Show Container")
            {
                ApplicationArea = Suite;
                Caption = '&Container';
                Image = ResourceGroup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Shows Items in the container';
                trigger OnAction()
                var
                    ContMgmt: Codeunit "Container Mgmt. ELA";
                    WhseDocType: enum "Whse. Doc. Type ELA";
                    SourceDocTypeFilter: enum "WMS Source Doc Type ELA";
                    ActivityType: Enum "WMS Activity Type ELA";
                begin
                    ContMgmt.ShowContainer(SourceDocTypeFilter, '', "Location Code", 0, '', WhseDocType::Receipt,
                         Rec."No.", ActivityType, '');
                end;
            }

            action("Assign Container Contents")
            {
                ApplicationArea = Warehouse;
                Promoted = true;
                PromotedCategory = Process;
                image = Create;
                trigger OnAction()
                var
                    AssignContContents: Page "Assign Container Contents ELA";
                    WhseDocType: Enum "Whse. Doc. Type ELA";
                    SourceDocTypeFilter: Enum "WMS Source Doc Type ELA";
                    ActivityType: Enum "WMS Activity Type ELA";
                begin
                    AssignContContents.SetDocumentFilters(SourceDocTypeFilter, 1, rec."Source No.", 0,
                        WhseDocType::Receipt, Rec."No.", ActivityType::"Put-away", '', 0, '', false);
                    AssignContContents.Run();
                end;
            }

        }
    }
    trigger OnAfterGetRecord()
    var
        gcodTrackingStatus: Codeunit "EN Custom Functions";
        ldecPct: Decimal;
        lblnItemTracking: Boolean;
    begin

        // SetStatus; //<JF49590SHR>

        //<WC32455WC>
        ldecPct := ROUND(doTrackingExistsELA("Qty. (Base)", lblnItemTracking));
        txtTrackingStatus := gcodTrackingStatus.UpdateTrackingStatus(ldecPct, lblnItemTracking);
        StyleTxt := gcodTrackingStatus.SetStyle(ldecPct, lblnItemTracking);
    end;

    procedure isGetUOMSizeCode(): CODE[20]
    var
        lrecItemUOM: Record "Item Unit of Measure";
    begin
        IF "Item No." = '' THEN EXIT('');
        IF "Unit of Measure Code" = '' THEN EXIT('');
        IF lrecItemUOM.GET("Item No.", "Unit of Measure Code") THEN;
        EXIT(lrecItemUOM."Item UOM Size Code ELA");
    end;

    var
        txtTrackingStatus: Code[20];
        StyleTxt: Text[50];

}