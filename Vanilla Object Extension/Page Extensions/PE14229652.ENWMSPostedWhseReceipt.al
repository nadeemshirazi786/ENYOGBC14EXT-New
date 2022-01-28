/// <summary>
/// PageExtension EN WMS Posted Whse. Receipt (ID 14229241) extends Record Posted Whse. Receipt.
/// </summary>
pageextension 14229241 "WMS Posted Whse. Receipt ELA" extends "Posted Whse. Receipt"
{
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
                         Rec."Whse. Receipt No.", ActivityType, '');
                end;
            }

        }
    }
}
