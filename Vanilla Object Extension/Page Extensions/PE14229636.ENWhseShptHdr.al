pageextension 14229636 "Whse Shpt ELA" extends "Warehouse Shipment"
{
    layout
    {
        addafter("Shipment Method Code")
        {
            field("Seal No."; "Seal No. ELA")
            {
                ApplicationArea = All;
            }
        }
		addafter("Sorting Method")
        {
            field("WMS Assigned Role"; Rec."Assigned App. Role ELA")
            {
                ApplicationArea = All;
            }

            field("WMS Assigned to"; "Assigned To ELA")
            {
                ApplicationArea = All;
            }

            field("Trip No."; "Trip No. ELA")
            {
                ApplicationArea = All;
                Editable = false;
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
                    ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', "Location Code", 1, '', WhseDocType::Shipment, "No.",
                  ActivityType, '');
                end;
            }
        }
    }

    var
        myInt: Integer;
}