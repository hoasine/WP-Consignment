report 70004 "Purchase & Return Details"
{
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70004.PurchaseReturnDetail.rdl';

    dataset
    {
        //"Transaction No.", "Line No.", "Store No.", "Receipt No.", "USER SID"
        dataitem("Consignment Entries"; "Consignment Entries")
        {
            RequestFilterFields = "date", "Store No.", "Vendor No.", "Vendor Posting group", "Item Family Code", "Division", "Item Category", "Product Group", "Item No.";
            UseTemporary = true;
            column(DateFilter; DateFilter) { }
            column(Outlet; "Store No.") { }
            column(SupplierCode; "Vendor No.") { }
            column(Supplier; gVenDesc) { }
            column(YYYY_MM; LDateFor) { }
            column(ItemCode; "Item No.") { }
            column(ItemDescription; gItemDesc) { }
            column(Quantity; Quantity) { } //CR-00059
            column(GRAmount; "Gross Price") { }
            column(DNAmount; "Discount Amount") { }
            column(NetAmount; "Net Amount") { }
            column(VATAmount; "VAT Amount") { }
            column(DocType; "Member Card No.") { }
            column(DivisionCode; "Item Family Code") { }
            column(DepartmentCode; Division) { }
            column(SubDepartmentCode; "Item Category") { }
            column(CategoryCode; "Product Group") { }
            column(DocumentNo; "Receipt No.") { }
            column(VendorInvoiceNo; "Item Description") { }

            trigger OnPreDataItem()
            begin
                DateFilter := "Consignment Entries".GetFilter(date);
                LocationFilter := "Consignment Entries".GetFilter("Store No.");
                VendorFilter := "Consignment Entries".GetFilter("Vendor No.");
                vpgfilter := "Consignment Entries".GetFilter("Vendor Posting Group");//20201016
                GenerateData();
            end;

            trigger OnAfterGetRecord()
            begin
                clear(gVenDesc);
                clear(recVend);
                if recvend.get("Consignment Entries"."Vendor No.") then
                    gVenDesc := recVend.Name;

                LDateFor := format("Consignment Entries".date, 0, '<Year4>-<Month,2>');

                clear(gItemDesc);
                clear(recitem);
                if recitem.get("Consignment Entries"."Item No.") then
                    gItemDesc := recitem.Description;

            end;

        }
    }

    trigger OnPreReport()
    begin
        recCompanyInfo.GET;
        recCompanyInfo.CALCFIELDS(Picture);
    end;

    local procedure GenerateData()
    var
        LRecPH: Record "Purch. Inv. Header";
        LRecPL: Record "Purch. Inv. Line";
        LRecCH: record "Purch. Cr. Memo Hdr.";
        LRecCL: Record "Purch. Cr. Memo Line";
        LRecIT: Record Item;
    // LRecTFP: Record "LS TFP Setup";
    begin
        // if LRecTFP.Get() then; //Obsolete
        clear(NextLineNo);
        clear(LRecPH);
        if VendorFilter <> '' then
            LRecPH.SetFilter("Buy-from Vendor No.", VendorFilter);
        if vpgfilter <> '' then
            lrecph.setfilter("Vendor Posting Group", vpgfilter);//20201016
        if DateFilter <> '' then
            lrecph.setfilter("Posting Date", DateFilter);
        if LocationFilter <> '' then
            lrecph.setfilter("Location Code", LocationFilter);
        if lrecph.FindFirst() then begin
            repeat
                //Type Item-
                clear(lrecpl);
                lrecpl.setrange("Document No.", lrecph."No.");
                lrecpl.setrange(Type, lrecpl.type::Item);
                lrecpl.setfilter("no.", '<>''''');//20201019
                //lrecpl.setfilter("Posted Item No.", '<>''''');//20201014
                if lrecpl.FindFirst() then begin
                    repeat
                        NextLineNo += 1;
                        "Consignment Entries".reset;
                        "Consignment Entries"."Transaction No." := 1;
                        "Consignment Entries"."Line No." := NextLineNo;
                        "Consignment Entries".Date := lrecph."Posting Date";
                        "Consignment Entries"."Receipt No." := lrecpl."Document No.";
                        "Consignment Entries"."Store No." := lrecpl."Location Code";
                        "Consignment Entries"."USER SID" := UserSecurityId();
                        "Consignment Entries"."Vendor No." := lrecph."Buy-from Vendor No.";
                        //Obsolete-
                        // if lrecpl."Posted Item No." <> '' then
                        //     "Consignment Entries"."Item No." := lrecpl."Posted Item No."
                        // else
                        //Obsolete+
                        "Consignment Entries"."Item No." := lrecpl."No.";
                        "Consignment Entries"."VAT Amount" := lrecpl."Amount Including VAT" - lrecpl.Amount;
                        "Consignment Entries"."Item Description" := lrecph."Vendor Invoice No.";
                        clear(LRecIT);
                        if lrecit.get("Consignment Entries"."Item No.") then;
                        "Consignment Entries"."Item Family Code" := lrecit."LSC Item Family Code";
                        "Consignment Entries".Division := lrecit."LSC Division Code";
                        "Consignment Entries"."Item Category" := lrecit."Item Category Code";
                        "Consignment Entries"."Product Group" := lrecit."LSC Retail Product Code";
                        "Consignment Entries"."Member Card No." := 'GRN';
                        "Consignment Entries"."Gross Price" := lrecpl."Amount Including VAT";
                        "Consignment Entries"."Net Amount" := lrecpl."Amount Including VAT";// - lrecpl."Line Discount Amount";
                        "Consignment Entries".Quantity := LRecPL.Quantity; //CR-00059
                        "Consignment Entries".Insert;
                    until lrecpl.next = 0;
                end;
                //Type Item+

                //Type G/L-
                clear(lrecpl);
                lrecpl.setrange("Document No.", lrecph."No.");
                lrecpl.setrange(Type, lrecpl.type::"G/L Account");
                // LRecPL.SetRange("No.", LRecTFP."LS G/L Account No. (AutoDN)"); //Obsolete
                // lrecpl.setfilter("no.", '<>''''');//20201019
                // lrecpl.setfilter("Posted Item No.", '<>''''');//20201014
                if lrecpl.FindFirst() then begin
                    repeat
                        NextLineNo += 1;
                        "Consignment Entries".reset;
                        "Consignment Entries"."Transaction No." := 1;
                        "Consignment Entries"."Line No." := NextLineNo;
                        "Consignment Entries".Date := lrecph."Posting Date";
                        "Consignment Entries"."Receipt No." := lrecpl."Document No.";
                        "Consignment Entries"."Store No." := lrecpl."Location Code";
                        "Consignment Entries"."USER SID" := UserSecurityId();
                        "Consignment Entries"."Vendor No." := lrecph."Buy-from Vendor No.";
                        //Obsolete-
                        // if lrecpl."Posted Item No." <> '' then
                        //     "Consignment Entries"."Item No." := lrecpl."Posted Item No."
                        // else
                        //Obsolete+
                        "Consignment Entries"."Item No." := lrecpl."No.";
                        "Consignment Entries"."VAT Amount" := lrecpl."Amount Including VAT" - lrecpl.Amount;
                        "Consignment Entries"."Item Description" := lrecph."Vendor Invoice No.";
                        clear(LRecIT);
                        if lrecit.get("Consignment Entries"."Item No.") then;
                        "Consignment Entries"."Item Family Code" := lrecit."LSC Item Family Code";
                        "Consignment Entries".Division := lrecit."LSC Division Code";
                        "Consignment Entries"."Item Category" := lrecit."Item Category Code";
                        "Consignment Entries"."Product Group" := lrecit."LSC Retail Product Code";
                        "Consignment Entries"."Member Card No." := 'GRN';
                        "Consignment Entries"."Gross Price" := lrecpl."Amount Including VAT";
                        "Consignment Entries"."Net Amount" := lrecpl."Amount Including VAT";// - lrecpl."Line Discount Amount";
                        "Consignment Entries".Quantity := LRecPL.Quantity;
                        "Consignment Entries".Insert;
                    until lrecpl.next = 0;
                end;
            //Type G/L+
            until lrecph.next = 0;
        end;

        clear(lrecch);
        if VendorFilter <> '' then
            LReccH.SetFilter("Buy-from Vendor No.", VendorFilter);
        if vpgfilter <> '' then
            lrecch.SetFilter("Vendor Posting Group", vpgfilter);//20201016
        if DateFilter <> '' then
            lrecch.setfilter("Posting Date", DateFilter);
        if LocationFilter <> '' then
            lrecch.setfilter("Location Code", LocationFilter);
        if lrecch.FindFirst() then begin
            repeat
                clear(lreccl);
                lreccl.setrange("Document No.", lrecch."No.");
                LRecCL.SetRange(Type, LRecCL.type::Item); //20210819-
                lreccl.setfilter("no.", '<>''''');//20201019
                // lreccl.setfilter("posted item No.", '<>''''');//20201014
                if lreccl.FindFirst() then begin
                    repeat
                        NextLineNo += 1;
                        "Consignment Entries".reset;
                        "Consignment Entries"."Transaction No." := 1;
                        "Consignment Entries"."Line No." := NextLineNo;
                        "Consignment Entries".Date := lrecch."Posting Date";
                        "Consignment Entries"."Receipt No." := lreccl."Document No.";
                        "Consignment Entries"."Store No." := lreccl."Location Code";
                        "Consignment Entries"."USER SID" := UserSecurityId();
                        "Consignment Entries"."Vendor No." := lreccH."Buy-from Vendor No.";
                        //Obsolete-
                        // if lreccl."Posted Item No." <> '' then
                        //     "Consignment Entries"."Item No." := lreccl."Posted Item No."
                        // else
                        //Obsolete+
                        "Consignment Entries"."Item No." := lreccl."No.";
                        "Consignment Entries"."VAT Amount" := lreccl."Amount Including VAT" - lreccl.Amount;
                        "Consignment Entries"."Item Description" := lrecch."Vendor Cr. Memo No.";

                        clear(LRecIT);
                        if lrecit.get("Consignment Entries"."item No.") then;
                        "Consignment Entries"."Item Family Code" := lrecit."LSC Item Family Code";
                        "Consignment Entries".Division := lrecit."LSC Division Code";
                        "Consignment Entries"."Item Category" := lrecit."Item Category Code";
                        "Consignment Entries"."Product Group" := lrecit."LSC Retail Product Code";
                        if lreccl.type = lreccl.type::item then begin
                            "Consignment Entries"."Member Card No." := 'PRDN';
                            clear("Consignment Entries"."Gross Price");//20201019
                            "Consignment Entries"."Discount Amount" := -lreccl."Amount Including VAT";//20201014
                        end else begin
                            "Consignment Entries"."Member Card No." := 'GRDA';
                            clear("Consignment Entries"."discount amount");//20201019
                            "Consignment Entries"."Gross Price" := -lreccl."Amount Including VAT";//20201014
                        end;
                        "Consignment Entries"."Net Amount" := -(lreccl."Amount Including VAT");// - lreccl."Line Discount Amount");//20201015
                        "Consignment Entries".Quantity := LRecCL.Quantity; //CR-00059
                        "Consignment Entries".insert;
                    until lreccl.next = 0;
                end;

                //GL-
                clear(lreccl);
                lreccl.setrange("Document No.", lrecch."No.");
                LRecCL.SetRange(Type, LRecCL.type::"G/L Account"); //20210819-
                // LRecCL.SetRange("No.", LRecTFP."LS G/L Account No. (AutoDN)"); //Obsolete
                // lreccl.setfilter("no.", '<>''''');//20201019
                // lreccl.setfilter("posted item No.", '<>''''');//20201014
                if lreccl.FindFirst() then begin
                    repeat
                        NextLineNo += 1;
                        "Consignment Entries".reset;
                        "Consignment Entries"."Transaction No." := 1;
                        "Consignment Entries"."Line No." := NextLineNo;
                        "Consignment Entries".Date := lrecch."Posting Date";
                        "Consignment Entries"."Receipt No." := lreccl."Document No.";
                        "Consignment Entries"."Store No." := lreccl."Location Code";
                        "Consignment Entries"."USER SID" := UserSecurityId();
                        "Consignment Entries"."Vendor No." := lreccH."Buy-from Vendor No.";
                        //Obsolete-
                        // if lreccl."Posted Item No." <> '' then
                        //     "Consignment Entries"."Item No." := lreccl."Posted Item No."
                        // else
                        //Obsolete+
                        "Consignment Entries"."Item No." := lreccl."No.";
                        "Consignment Entries"."VAT Amount" := lreccl."Amount Including VAT" - lreccl.Amount;
                        "Consignment Entries"."Item Description" := lrecch."Vendor Cr. Memo No.";

                        clear(LRecIT);
                        if lrecit.get("Consignment Entries"."item No.") then;
                        "Consignment Entries"."Item Family Code" := lrecit."LSc Item Family Code";
                        "Consignment Entries".Division := lrecit."LSC Division Code";
                        "Consignment Entries"."Item Category" := lrecit."Item Category Code";
                        "Consignment Entries"."Product Group" := lrecit."LSc Retail Product Code";
                        if lreccl.type = lreccl.type::item then begin
                            "Consignment Entries"."Member Card No." := 'PRDN';
                            clear("Consignment Entries"."Gross Price");//20201019
                            "Consignment Entries"."Discount Amount" := -lreccl."Amount Including VAT";//20201014
                        end else begin
                            "Consignment Entries"."Member Card No." := 'GRDA';
                            clear("Consignment Entries"."discount amount");//20201019
                            "Consignment Entries"."Gross Price" := -lreccl."Amount Including VAT";//20201014
                        end;
                        "Consignment Entries"."Net Amount" := -(lreccl."Amount Including VAT");// - lreccl."Line Discount Amount");//20201015
                        "Consignment Entries".Quantity := LRecCL.Quantity; //CR-00059
                        "Consignment Entries".insert;
                    until lreccl.next = 0;
                end;
                //GL+

                //Charge Item-
                clear(lreccl);
                lreccl.setrange("Document No.", lrecch."No.");
                LRecCL.SetRange(Type, LRecCL.type::"Charge (Item)"); //20210819-
                // LRecCL.SetRange("No.", LRecTFP."LS Charge of Account (AutoDN)"); //Obsolete-
                // lreccl.setfilter("no.", '<>''''');//20201019
                // lreccl.setfilter("posted item No.", '<>''''');//20201014
                if lreccl.FindFirst() then begin
                    repeat
                        NextLineNo += 1;
                        "Consignment Entries".reset;
                        "Consignment Entries"."Transaction No." := 1;
                        "Consignment Entries"."Line No." := NextLineNo;
                        "Consignment Entries".Date := lrecch."Posting Date";
                        "Consignment Entries"."Receipt No." := lreccl."Document No.";
                        "Consignment Entries"."Store No." := lreccl."Location Code";
                        "Consignment Entries"."USER SID" := UserSecurityId();
                        "Consignment Entries"."Vendor No." := lreccH."Buy-from Vendor No.";
                        //Obsolete-
                        // if lreccl."Posted Item No." <> '' then
                        //     "Consignment Entries"."Item No." := lreccl."Posted Item No."
                        // else
                        //Obsolete+
                        "Consignment Entries"."Item No." := lreccl."No.";
                        "Consignment Entries"."VAT Amount" := lreccl."Amount Including VAT" - lreccl.Amount;
                        "Consignment Entries"."Item Description" := lrecch."Vendor Cr. Memo No.";

                        clear(LRecIT);
                        if lrecit.get("Consignment Entries"."item No.") then;
                        "Consignment Entries"."Item Family Code" := lrecit."LSC Item Family Code";
                        "Consignment Entries".Division := lrecit."LSC Division Code";
                        "Consignment Entries"."Item Category" := lrecit."Item Category Code";
                        "Consignment Entries"."Product Group" := lrecit."LSC Retail Product Code";
                        if lreccl.type = lreccl.type::item then begin
                            "Consignment Entries"."Member Card No." := 'PRDN';
                            clear("Consignment Entries"."Gross Price");//20201019
                            "Consignment Entries"."Discount Amount" := -lreccl."Amount Including VAT";//20201014
                        end else begin
                            "Consignment Entries"."Member Card No." := 'GRDA';
                            clear("Consignment Entries"."discount amount");//20201019
                            "Consignment Entries"."Gross Price" := -lreccl."Amount Including VAT";//20201014
                        end;
                        "Consignment Entries"."Net Amount" := -(lreccl."Amount Including VAT");// - lreccl."Line Discount Amount");//20201015
                        "Consignment Entries".Quantity := LRecCL.Quantity; //CR-00059
                        "Consignment Entries".insert;
                    until lreccl.next = 0;
                end;
            //Charge Item+
            until lrecch.next = 0;
        end;
    end;

    var

        recCompanyInfo: Record "Company Information";
        recVend: Record Vendor;

        DateFilter: text[250];
        LocationFilter: text;
        VendorFilter: text;
        NextLineNo: Integer;

        LDateFor: text[7];//20200930
        gRecIF: Record "LSc Item Family";//20200930
        gRecDI: Record "LSC Division";//20200930
        grecIC: Record "Item Category";//20200930
        grecRP: Record "LSC Retail Product Group";//20200930
        gIFDesc: text;//20200930
        gDIDesc: text;//20200930
        gICDesc: text;//20200930
        gRPDesc: text;//20200930
        gVenDesc: text;
        RecItem: Record item;
        gItemDesc: text;
        vpgfilter: text;//20201016
}