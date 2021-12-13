/// <summary>
/// Page EN Price List Group (ID 14228852).
/// </summary>
page 14228853 "EN Price List Group"
{

    ApplicationArea = All;
    Caption = 'EN Price List Group';
    PageType = List;
    SourceTable = "EN Price List Group";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // Procedure GetSelectionFilter(): Text
    // begin
    //     CurrPage.SETSELECTIONFILTER();
    //     EXIT(SelectionFilterManagement.GetSelectionFilterForCampaign(Campaign));
    // end;
    // var 
    //     SelectionFilterManagement:Codeunit SelectionFilterManagement;
}
