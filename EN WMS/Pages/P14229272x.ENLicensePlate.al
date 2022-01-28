//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN License Plate (ID 14229222).
/// </summary>
page 14229272 "License Plate ELA"
{
    Caption = 'License Plate';
    PageType = Document;
    SourceTable = "License Plate ELA";
    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                // field(Status; Rec.Status)
                // {
                //     ApplicationArea = All;
                // }

                field(Type; Type)
                {
                    ApplicationArea = All;
                }

                field("Last Updated By"; Rec."Last Updated By")
                {
                    ApplicationArea = All;
                }
                field("Last Updated On"; Rec."Last Updated On")
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
            }

            part(LicensePlateLines; "License Plate SubformX ELA")
            {
                ApplicationArea = basic, suite;
                // SubPageLink = "License Plate No." = field("License No.");
                UpdatePropagation = both;
            }
        }
    }

}
