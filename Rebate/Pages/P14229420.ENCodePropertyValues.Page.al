page 14229420 "Code Property Values ELA"
{


    // ENRE1.00 2021-09-08 AJ
    Caption = 'Code Property Values';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5,Category6,Category7,Category8,Category9,Picture';
    SourceTable = "Code Property Value ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Property Code"; "Property Code")
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    // actions
    // {
    //     area(processing)
    //     {
    //         group("&Picture")
    //         {
    //             Caption = '&Picture';
    //             action(Import)
    //             {
    //                 ApplicationArea = All;
    //                 Caption = 'Import';
    //                 Image = Import;
    //                 Promoted = true;
    //                 PromotedCategory = Category10;

    //                 trigger OnAction()
    //                 begin
    //                     picImport;
    //                     CalcFields(Picture);
    //                 end;
    //             }
    //             action("E&xport")
    //             {
    //                 ApplicationArea = All;
    //                 Caption = 'E&xport';
    //                 Image = Export;
    //                 Promoted = true;
    //                 PromotedCategory = Category10;

    //                 trigger OnAction()
    //                 begin
    //                     picExport;
    //                     CalcFields(Picture);
    //                 end;
    //             }
    //             action(Remove)
    //             {
    //                 ApplicationArea = All;
    //                 Caption = 'Remove';
    //                 Image = Delete;
    //                 Promoted = true;
    //                 PromotedCategory = Category10;

    //                 trigger OnAction()
    //                 begin
    //                     picDelete;
    //                     CalcFields(Picture);
    //                 end;
    //             }
    //         }
    //     }
    // }

    var
        PictureExists: Boolean;
        Text001: Label 'Do you want to replace the existing picture?';
        Text002: Label 'Do you want to delete the picture?';
}

