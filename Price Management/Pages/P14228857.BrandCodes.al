/// <summary>
/// Page Brand Codes (ID 14228857).
/// </summary>
page 14228857 "EN Brand Codes"
{

    ApplicationArea = All;
    Caption = 'EN Brand Codes';
    PageType = List;
    SourceTable = "EN Brand Code";
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
                field("Private Label"; Rec."Private Label")
                {
                    ToolTip = 'Specifies the value of the Private Label field';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        
    }

}
