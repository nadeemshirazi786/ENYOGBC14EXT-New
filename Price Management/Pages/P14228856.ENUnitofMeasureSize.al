/// <summary>
/// Page EN Unit of Measure Size (ID 14228856).
/// </summary>
page 14228856 "EN Unit of Measure Size"
{

    ApplicationArea = All;
    Caption = 'EN Unit of Measure Size';
    PageType = List;
    SourceTable = "EN Unit of Measure Size";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {

    }
}
