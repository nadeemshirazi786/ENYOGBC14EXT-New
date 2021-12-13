codeunit 14229121 "Repack-Post (Yes/No)"
{
    TableNo = "EN Repack Order";

    trigger OnRun()
    begin
        RepackOrder.Copy(Rec);
        Code;
        Rec := RepackOrder;
    end;

    var
        RepackOrder: Record "EN Repack Order";
        RepackLine: Record "EN Repack Order Line";
        Selection: Integer;
        Text001: Label '&Transfer,&Produce,Transfer &and Produce';
        RepackPost: Codeunit "Repack-Post";


    procedure "Code"()
    begin
        RepackLine.SetRange("Order No.", RepackOrder."No.");
        RepackLine.SetFilter("Quantity to Transfer", '>0');
        if RepackLine.IsEmpty then
            Selection := 2
        else
            Selection := 1;

        Selection := StrMenu(Text001, Selection);
        if Selection = 0 then
            exit;
        RepackOrder.Transfer := Selection in [1, 3];
        RepackOrder.Produce := Selection in [2, 3];

        RepackPost.Run(RepackOrder);
    end;
}

