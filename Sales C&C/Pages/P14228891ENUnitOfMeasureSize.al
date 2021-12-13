page 14228891 "Unit Of Measure Size ELA"
{

    Caption = 'Unit Of Measure Size';
    PageType = List;
    UsageCategory = Lists;
    InsertAllowed = true;
    Editable = true;
    DeleteAllowed = true;
    SourceTable = "Unit Of Measure Size ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; "Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
