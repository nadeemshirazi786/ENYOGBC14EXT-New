/// <summary>
/// Page EN Customer Buying Group (ID 14228852).
/// </summary>
page 14228852 "EN Customer Buying Group"
{

    ApplicationArea = All;
    Caption = 'Customer Buying Group';
    PageType = List;
    SourceTable = "EN Customer Buying Group";
    UsageCategory = Lists;
    InsertAllowed = true;


    layout
    {
        area(content)
        {
            repeater(Group)
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

}
