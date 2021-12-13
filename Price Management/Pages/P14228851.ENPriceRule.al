/// <summary>
/// Page EN Price Rule (ID 14228851).
/// </summary>
page 14228851 "EN Price Rule"
{

    ApplicationArea = All;
    Caption = 'EN Price Rule';
    PageType = List;
    SourceTable = "EN Price Rule";
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
                field("Price Evaluation Rank"; Rec."Price Evaluation Rank")
                {
                    ApplicationArea = All;
                }
                field("Customer Rank"; Rec."Customer Rank")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Modifier Rank"; Rec."Ship-to Modifier Rank")
                {
                    ApplicationArea = All;
                }
                field("Buying Group Rank"; Rec."Buying Group Rank")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group Rank"; Rec."Customer Price Group Rank")
                {
                    ApplicationArea = All;
                }
                field("List Price Group Rank"; Rec."List Price Group Rank")
                {
                    ApplicationArea = All;
                }
                field("Campaign Rank"; Rec."Campaign Rank")
                {
                    ApplicationArea = All;
                }
                field("All Customer Rank"; Rec."All Customer Rank")
                {
                    ApplicationArea = All;
                }
                field("Contract Price Modifier Rank"; Rec."Contract Price Modifier Rank")
                {
                    ApplicationArea = All;
                }
                field("Variant Modifier Rank"; Rec."Variant Modifier Rank")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Modifier Rank"; Rec."Unit of Measure Modifier Rank")
                {
                    ApplicationArea = All;
                }
                field("Quantity Modifier Rank"; Rec."Quantity Modifier Rank")
                {
                    ApplicationArea = All;
                }
                field("End Date Modifier Rank"; Rec."End Date Modifier Rank")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
