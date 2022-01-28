//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Container Types (ID 14229225).
/// </summary>
page 14229225 "Container Types ELA"
{

    ApplicationArea = All, Warehouse;
    Caption = 'Container Types';
    PageType = List;
    SourceTable = "Conatiner Type ELA";
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
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }
                field("Tare Weight"; Rec."Tare Weight")
                {
                    ApplicationArea = All;
                }
                field("Tare Unit of Measure"; Rec."Tare Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(Capcity; Rec.Capcity)
                {
                    ApplicationArea = All;
                }
                field("Capacity Unit of Measure"; Rec."Capacity Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Default Report ID"; Rec."Default Report ID")
                {
                    ApplicationArea = All;
                }
                field("No. of Labels"; Rec."No. of Labels")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
