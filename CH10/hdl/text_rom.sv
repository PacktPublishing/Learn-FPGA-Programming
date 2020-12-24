module text_rom
  (
   input              clock, // Clock
   input [7:0]        index, // Character Index
   input [2:0]        sub_index, // Y position in character

   output logic [7:0] bitmap_out         // 8 bit horizontal slice of character
   );

  logic [7:0]         bitmap;         // 8 bit horizontal slice of character
  always @* begin
    for (int i = 0; i < 8; i++) begin
      bitmap_out[i] = bitmap[7-i];
    end
  end
  always @(posedge clock)
    case ({index, sub_index})
      // Middle Fill Bar - Empty
      {8'h00, 3'h0}: bitmap <= 8'h00;
      {8'h00, 3'h1}: bitmap <= 8'hFF;
      {8'h00, 3'h2}: bitmap <= 8'h00;
      {8'h00, 3'h3}: bitmap <= 8'h00;
      {8'h00, 3'h4}: bitmap <= 8'h00;
      {8'h00, 3'h5}: bitmap <= 8'h00;
      {8'h00, 3'h6}: bitmap <= 8'hFF;
      {8'h00, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - 1/8
      {8'h01, 3'h0}: bitmap <= 8'h00;
      {8'h01, 3'h1}: bitmap <= 8'hFF;
      {8'h01, 3'h2}: bitmap <= 8'h80;
      {8'h01, 3'h3}: bitmap <= 8'h80;
      {8'h01, 3'h4}: bitmap <= 8'h80;
      {8'h01, 3'h5}: bitmap <= 8'h80;
      {8'h01, 3'h6}: bitmap <= 8'hFF;
      {8'h01, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - 2/8
      {8'h02, 3'h0}: bitmap <= 8'h00;
      {8'h02, 3'h1}: bitmap <= 8'hFF;
      {8'h02, 3'h2}: bitmap <= 8'hC0;
      {8'h02, 3'h3}: bitmap <= 8'hC0;
      {8'h02, 3'h4}: bitmap <= 8'hC0;
      {8'h02, 3'h5}: bitmap <= 8'hC0;
      {8'h02, 3'h6}: bitmap <= 8'hFF;
      {8'h02, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - 3/8
      {8'h03, 3'h0}: bitmap <= 8'h00;
      {8'h03, 3'h1}: bitmap <= 8'hFF;
      {8'h03, 3'h2}: bitmap <= 8'hE0;
      {8'h03, 3'h3}: bitmap <= 8'hE0;
      {8'h03, 3'h4}: bitmap <= 8'hE0;
      {8'h03, 3'h5}: bitmap <= 8'hE0;
      {8'h03, 3'h6}: bitmap <= 8'hFF;
      {8'h03, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - 4/8
      {8'h04, 3'h0}: bitmap <= 8'h00;
      {8'h04, 3'h1}: bitmap <= 8'hFF;
      {8'h04, 3'h2}: bitmap <= 8'hF0;
      {8'h04, 3'h3}: bitmap <= 8'hF0;
      {8'h04, 3'h4}: bitmap <= 8'hF0;
      {8'h04, 3'h5}: bitmap <= 8'hF0;
      {8'h04, 3'h6}: bitmap <= 8'hFF;
      {8'h04, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - 5/8
      {8'h05, 3'h0}: bitmap <= 8'h00;
      {8'h05, 3'h1}: bitmap <= 8'hFF;
      {8'h05, 3'h2}: bitmap <= 8'hF8;
      {8'h05, 3'h3}: bitmap <= 8'hF8;
      {8'h05, 3'h4}: bitmap <= 8'hF8;
      {8'h05, 3'h5}: bitmap <= 8'hF8;
      {8'h05, 3'h6}: bitmap <= 8'hFF;
      {8'h05, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - 6/8
      {8'h06, 3'h0}: bitmap <= 8'h00;
      {8'h06, 3'h1}: bitmap <= 8'hFF;
      {8'h06, 3'h2}: bitmap <= 8'hFC;
      {8'h06, 3'h3}: bitmap <= 8'hFC;
      {8'h06, 3'h4}: bitmap <= 8'hFC;
      {8'h06, 3'h5}: bitmap <= 8'hFC;
      {8'h06, 3'h6}: bitmap <= 8'hFF;
      {8'h06, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - 7/8
      {8'h07, 3'h0}: bitmap <= 8'h00;
      {8'h07, 3'h1}: bitmap <= 8'hFF;
      {8'h07, 3'h2}: bitmap <= 8'hFE;
      {8'h07, 3'h3}: bitmap <= 8'hFE;
      {8'h07, 3'h4}: bitmap <= 8'hFE;
      {8'h07, 3'h5}: bitmap <= 8'hFE;
      {8'h07, 3'h6}: bitmap <= 8'hFF;
      {8'h07, 3'h7}: bitmap <= 8'h00;
      // Middle Fill Bar - Full
      {8'h08, 3'h0}: bitmap <= 8'h00;
      {8'h08, 3'h1}: bitmap <= 8'hFF;
      {8'h08, 3'h2}: bitmap <= 8'hFF;
      {8'h08, 3'h3}: bitmap <= 8'hFF;
      {8'h08, 3'h4}: bitmap <= 8'hFF;
      {8'h08, 3'h5}: bitmap <= 8'hFF;
      {8'h08, 3'h6}: bitmap <= 8'hFF;
      {8'h08, 3'h7}: bitmap <= 8'h00;
      // Left edge of fill bar
      {8'h09, 3'h0}: bitmap <= 8'h00;
      {8'h09, 3'h1}: bitmap <= 8'h00;
      {8'h09, 3'h2}: bitmap <= 8'h01;
      {8'h09, 3'h3}: bitmap <= 8'h01;
      {8'h09, 3'h4}: bitmap <= 8'h01;
      {8'h09, 3'h5}: bitmap <= 8'h01;
      {8'h09, 3'h6}: bitmap <= 8'h00;
      {8'h09, 3'h7}: bitmap <= 8'h00;
      // Right edge of fill bar
      {8'h0A, 3'h0}: bitmap <= 8'h00;
      {8'h0A, 3'h1}: bitmap <= 8'h00;
      {8'h0A, 3'h2}: bitmap <= 8'h80;
      {8'h0A, 3'h3}: bitmap <= 8'h80;
      {8'h0A, 3'h4}: bitmap <= 8'h80;
      {8'h0A, 3'h5}: bitmap <= 8'h80;
      {8'h0A, 3'h6}: bitmap <= 8'h00;
      {8'h0A, 3'h7}: bitmap <= 8'h00;
      // Copyright Symbol
      {8'h0B, 3'h0}: bitmap <= 8'h3C;
      {8'h0B, 3'h1}: bitmap <= 8'h42;
      {8'h0B, 3'h2}: bitmap <= 8'h5A;
      {8'h0B, 3'h3}: bitmap <= 8'h52;
      {8'h0B, 3'h4}: bitmap <= 8'h5A;
      {8'h0B, 3'h5}: bitmap <= 8'h42;
      {8'h0B, 3'h6}: bitmap <= 8'h3C;
      {8'h0B, 3'h7}: bitmap <= 8'h00;
      // Degree Symbol
      {8'h0C, 3'h0}: bitmap <= 8'h38;
      {8'h0C, 3'h1}: bitmap <= 8'h44;
      {8'h0C, 3'h2}: bitmap <= 8'h44;
      {8'h0C, 3'h3}: bitmap <= 8'h44;
      {8'h0C, 3'h4}: bitmap <= 8'h38;
      {8'h0C, 3'h5}: bitmap <= 8'h00;
      {8'h0C, 3'h6}: bitmap <= 8'h00;
      {8'h0C, 3'h7}: bitmap <= 8'h00;
      // Space
      {8'h20, 3'h0}: bitmap <= 8'h00;
      {8'h20, 3'h1}: bitmap <= 8'h00;
      {8'h20, 3'h2}: bitmap <= 8'h00;
      {8'h20, 3'h3}: bitmap <= 8'h00;
      {8'h20, 3'h4}: bitmap <= 8'h00;
      {8'h20, 3'h5}: bitmap <= 8'h00;
      {8'h20, 3'h6}: bitmap <= 8'h00;
      {8'h20, 3'h7}: bitmap <= 8'h00;
      // "
      {8'h22, 3'h0}: bitmap <= 8'h6C;
      {8'h22, 3'h1}: bitmap <= 8'h6C;
      {8'h22, 3'h2}: bitmap <= 8'h6C;
      {8'h22, 3'h3}: bitmap <= 8'h00;
      {8'h22, 3'h4}: bitmap <= 8'h00;
      {8'h22, 3'h5}: bitmap <= 8'h00;
      {8'h22, 3'h6}: bitmap <= 8'h00;
      {8'h22, 3'h7}: bitmap <= 8'h00;
      // + - 178
      {8'h2B, 3'h0}: bitmap <= 8'h00;
      {8'h2B, 3'h1}: bitmap <= 8'h30;
      {8'h2B, 3'h2}: bitmap <= 8'h30;
      {8'h2B, 3'h3}: bitmap <= 8'hfc;
      {8'h2B, 3'h4}: bitmap <= 8'h30;
      {8'h2B, 3'h5}: bitmap <= 8'h30;
      {8'h2B, 3'h6}: bitmap <= 8'h00;
      {8'h2B, 3'h7}: bitmap <= 8'h00;
      // - - 178
      {8'h2D, 3'h0}: bitmap <= 8'h00;
      {8'h2D, 3'h1}: bitmap <= 8'h00;
      {8'h2D, 3'h2}: bitmap <= 8'h00;
      {8'h2D, 3'h3}: bitmap <= 8'hFC;
      {8'h2D, 3'h4}: bitmap <= 8'h00;
      {8'h2D, 3'h5}: bitmap <= 8'h00;
      {8'h2D, 3'h6}: bitmap <= 8'h00;
      {8'h2D, 3'h7}: bitmap <= 8'h00;
      // .
      {8'h2E, 3'h0}: bitmap <= 8'h00;
      {8'h2E, 3'h1}: bitmap <= 8'h00;
      {8'h2E, 3'h2}: bitmap <= 8'h00;
      {8'h2E, 3'h3}: bitmap <= 8'h00;
      {8'h2E, 3'h4}: bitmap <= 8'h00;
      {8'h2E, 3'h5}: bitmap <= 8'h30;
      {8'h2E, 3'h6}: bitmap <= 8'h30;
      {8'h2E, 3'h7}: bitmap <= 8'h00;
      // 0 - 1a0
      {8'h30, 3'h0}: bitmap <= 8'h7C;
      {8'h30, 3'h1}: bitmap <= 8'hC6;
      {8'h30, 3'h2}: bitmap <= 8'hCE;
      {8'h30, 3'h3}: bitmap <= 8'hD6;
      {8'h30, 3'h4}: bitmap <= 8'hE6;
      {8'h30, 3'h5}: bitmap <= 8'hC6;
      {8'h30, 3'h6}: bitmap <= 8'h7C;
      {8'h30, 3'h7}: bitmap <= 8'h00;
      // 1
      {8'h31, 3'h0}: bitmap <= 8'h30;
      {8'h31, 3'h1}: bitmap <= 8'h70;
      {8'h31, 3'h2}: bitmap <= 8'h30;
      {8'h31, 3'h3}: bitmap <= 8'h30;
      {8'h31, 3'h4}: bitmap <= 8'h30;
      {8'h31, 3'h5}: bitmap <= 8'h30;
      {8'h31, 3'h6}: bitmap <= 8'hFC;
      {8'h31, 3'h7}: bitmap <= 8'h00;
      // 2
      {8'h32, 3'h0}: bitmap <= 8'h78;
      {8'h32, 3'h1}: bitmap <= 8'hCC;
      {8'h32, 3'h2}: bitmap <= 8'h0C;
      {8'h32, 3'h3}: bitmap <= 8'h38;
      {8'h32, 3'h4}: bitmap <= 8'h60;
      {8'h32, 3'h5}: bitmap <= 8'hC0;
      {8'h32, 3'h6}: bitmap <= 8'hFC;
      {8'h32, 3'h7}: bitmap <= 8'h00;
      // 3
      {8'h33, 3'h0}: bitmap <= 8'h78;
      {8'h33, 3'h1}: bitmap <= 8'hCC;
      {8'h33, 3'h2}: bitmap <= 8'h0C;
      {8'h33, 3'h3}: bitmap <= 8'h38;
      {8'h33, 3'h4}: bitmap <= 8'h0C;
      {8'h33, 3'h5}: bitmap <= 8'hCC;
      {8'h33, 3'h6}: bitmap <= 8'h78;
      {8'h33, 3'h7}: bitmap <= 8'h00;
      // 4
      {8'h34, 3'h0}: bitmap <= 8'h1C;
      {8'h34, 3'h1}: bitmap <= 8'h34;
      {8'h34, 3'h2}: bitmap <= 8'h6C;
      {8'h34, 3'h3}: bitmap <= 8'hCC;
      {8'h34, 3'h4}: bitmap <= 8'hFE;
      {8'h34, 3'h5}: bitmap <= 8'h0C;
      {8'h34, 3'h6}: bitmap <= 8'h0C;
      {8'h34, 3'h7}: bitmap <= 8'h00;
      // 5
      {8'h35, 3'h0}: bitmap <= 8'hFC;
      {8'h35, 3'h1}: bitmap <= 8'hC0;
      {8'h35, 3'h2}: bitmap <= 8'hF8;
      {8'h35, 3'h3}: bitmap <= 8'h0C;
      {8'h35, 3'h4}: bitmap <= 8'h0C;
      {8'h35, 3'h5}: bitmap <= 8'hCC;
      {8'h35, 3'h6}: bitmap <= 8'h78;
      {8'h35, 3'h7}: bitmap <= 8'h00;
      // 6
      {8'h36, 3'h0}: bitmap <= 8'h38;
      {8'h36, 3'h1}: bitmap <= 8'h60;
      {8'h36, 3'h2}: bitmap <= 8'hC0;
      {8'h36, 3'h3}: bitmap <= 8'hF8;
      {8'h36, 3'h4}: bitmap <= 8'hCC;
      {8'h36, 3'h5}: bitmap <= 8'hCC;
      {8'h36, 3'h6}: bitmap <= 8'h78;
      {8'h36, 3'h7}: bitmap <= 8'h00;
      // 7
      {8'h37, 3'h0}: bitmap <= 8'hFC;
      {8'h37, 3'h1}: bitmap <= 8'h0C;
      {8'h37, 3'h2}: bitmap <= 8'h0C;
      {8'h37, 3'h3}: bitmap <= 8'h18;
      {8'h37, 3'h4}: bitmap <= 8'h30;
      {8'h37, 3'h5}: bitmap <= 8'h60;
      {8'h37, 3'h6}: bitmap <= 8'h60;
      {8'h37, 3'h7}: bitmap <= 8'h00;
      // 8
      {8'h38, 3'h0}: bitmap <= 8'h78;
      {8'h38, 3'h1}: bitmap <= 8'hCC;
      {8'h38, 3'h2}: bitmap <= 8'hCC;
      {8'h38, 3'h3}: bitmap <= 8'h78;
      {8'h38, 3'h4}: bitmap <= 8'hCC;
      {8'h38, 3'h5}: bitmap <= 8'hCC;
      {8'h38, 3'h6}: bitmap <= 8'h78;
      {8'h38, 3'h7}: bitmap <= 8'h00;
      // 9
      {8'h39, 3'h0}: bitmap <= 8'h78;
      {8'h39, 3'h1}: bitmap <= 8'hCC;
      {8'h39, 3'h2}: bitmap <= 8'hCC;
      {8'h39, 3'h3}: bitmap <= 8'h7C;
      {8'h39, 3'h4}: bitmap <= 8'h0C;
      {8'h39, 3'h5}: bitmap <= 8'h18;
      {8'h39, 3'h6}: bitmap <= 8'h70;
      {8'h39, 3'h7}: bitmap <= 8'h00;
      // :
      {8'h3A, 3'h0}: bitmap <= 8'h00;
      {8'h3A, 3'h1}: bitmap <= 8'h00;
      {8'h3A, 3'h2}: bitmap <= 8'h30;
      {8'h3A, 3'h3}: bitmap <= 8'h30;
      {8'h3A, 3'h4}: bitmap <= 8'h00;
      {8'h3A, 3'h5}: bitmap <= 8'h30;
      {8'h3A, 3'h6}: bitmap <= 8'h30;
      {8'h3A, 3'h7}: bitmap <= 8'h00;
      // @ - 220
      {8'h40, 3'h0}: bitmap <= 8'h7C;
      {8'h40, 3'h1}: bitmap <= 8'h82;
      {8'h40, 3'h2}: bitmap <= 8'h9E;
      {8'h40, 3'h3}: bitmap <= 8'hB6;
      {8'h40, 3'h4}: bitmap <= 8'h9E;
      {8'h40, 3'h5}: bitmap <= 8'h80;
      {8'h40, 3'h6}: bitmap <= 8'h78;
      {8'h40, 3'h7}: bitmap <= 8'h00;
      // A
      {8'h41, 3'h0}: bitmap <= 8'h30;
      {8'h41, 3'h1}: bitmap <= 8'h78;
      {8'h41, 3'h2}: bitmap <= 8'hCC;
      {8'h41, 3'h3}: bitmap <= 8'hCC;
      {8'h41, 3'h4}: bitmap <= 8'hFC;
      {8'h41, 3'h5}: bitmap <= 8'hCC;
      {8'h41, 3'h6}: bitmap <= 8'hCC;
      {8'h41, 3'h7}: bitmap <= 8'h00;
      // B
      {8'h42, 3'h0}: bitmap <= 8'hFC;
      {8'h42, 3'h1}: bitmap <= 8'h66;
      {8'h42, 3'h2}: bitmap <= 8'h66;
      {8'h42, 3'h3}: bitmap <= 8'h7C;
      {8'h42, 3'h4}: bitmap <= 8'h66;
      {8'h42, 3'h5}: bitmap <= 8'h66;
      {8'h42, 3'h6}: bitmap <= 8'hFC;
      {8'h42, 3'h7}: bitmap <= 8'h00;
      // C
      {8'h43, 3'h0}: bitmap <= 8'h3C;
      {8'h43, 3'h1}: bitmap <= 8'h66;
      {8'h43, 3'h2}: bitmap <= 8'hC0;
      {8'h43, 3'h3}: bitmap <= 8'hC0;
      {8'h43, 3'h4}: bitmap <= 8'hC0;
      {8'h43, 3'h5}: bitmap <= 8'h66;
      {8'h43, 3'h6}: bitmap <= 8'h3C;
      {8'h43, 3'h7}: bitmap <= 8'h00;
      // D
      {8'h44, 3'h0}: bitmap <= 8'hF8;
      {8'h44, 3'h1}: bitmap <= 8'h6C;
      {8'h44, 3'h2}: bitmap <= 8'h66;
      {8'h44, 3'h3}: bitmap <= 8'h66;
      {8'h44, 3'h4}: bitmap <= 8'h66;
      {8'h44, 3'h5}: bitmap <= 8'h6C;
      {8'h44, 3'h6}: bitmap <= 8'hF8;
      {8'h44, 3'h7}: bitmap <= 8'h00;
      // E
      {8'h45, 3'h0}: bitmap <= 8'hFE;
      {8'h45, 3'h1}: bitmap <= 8'hC2;
      {8'h45, 3'h2}: bitmap <= 8'hC8;
      {8'h45, 3'h3}: bitmap <= 8'hF8;
      {8'h45, 3'h4}: bitmap <= 8'hC8;
      {8'h45, 3'h5}: bitmap <= 8'hC2;
      {8'h45, 3'h6}: bitmap <= 8'hFE;
      {8'h45, 3'h7}: bitmap <= 8'h00;
      // F
      {8'h46, 3'h0}: bitmap <= 8'hFE;
      {8'h46, 3'h1}: bitmap <= 8'hC2;
      {8'h46, 3'h2}: bitmap <= 8'hC8;
      {8'h46, 3'h3}: bitmap <= 8'hF8;
      {8'h46, 3'h4}: bitmap <= 8'hC8;
      {8'h46, 3'h5}: bitmap <= 8'hC0;
      {8'h46, 3'h6}: bitmap <= 8'hC0;
      {8'h46, 3'h7}: bitmap <= 8'h00;
      // G
      {8'h47, 3'h0}: bitmap <= 8'h3C;
      {8'h47, 3'h1}: bitmap <= 8'h66;
      {8'h47, 3'h2}: bitmap <= 8'hC0;
      {8'h47, 3'h3}: bitmap <= 8'hC0;
      {8'h47, 3'h4}: bitmap <= 8'hCE;
      {8'h47, 3'h5}: bitmap <= 8'h66;
      {8'h47, 3'h6}: bitmap <= 8'h3E;
      {8'h47, 3'h7}: bitmap <= 8'h00;
      // H
      {8'h48, 3'h0}: bitmap <= 8'hC6;
      {8'h48, 3'h1}: bitmap <= 8'hC6;
      {8'h48, 3'h2}: bitmap <= 8'hC6;
      {8'h48, 3'h3}: bitmap <= 8'hFE;
      {8'h48, 3'h4}: bitmap <= 8'hC6;
      {8'h48, 3'h5}: bitmap <= 8'hC6;
      {8'h48, 3'h6}: bitmap <= 8'hC6;
      {8'h48, 3'h7}: bitmap <= 8'h00;
      // I
      {8'h49, 3'h0}: bitmap <= 8'h3C;
      {8'h49, 3'h1}: bitmap <= 8'h18;
      {8'h49, 3'h2}: bitmap <= 8'h18;
      {8'h49, 3'h3}: bitmap <= 8'h18;
      {8'h49, 3'h4}: bitmap <= 8'h18;
      {8'h49, 3'h5}: bitmap <= 8'h18;
      {8'h49, 3'h6}: bitmap <= 8'h3C;
      {8'h49, 3'h7}: bitmap <= 8'h00;
      // J
      {8'h4A, 3'h0}: bitmap <= 8'h0E;
      {8'h4A, 3'h1}: bitmap <= 8'h06;
      {8'h4A, 3'h2}: bitmap <= 8'h06;
      {8'h4A, 3'h3}: bitmap <= 8'h06;
      {8'h4A, 3'h4}: bitmap <= 8'h66;
      {8'h4A, 3'h5}: bitmap <= 8'h66;
      {8'h4A, 3'h6}: bitmap <= 8'h3C;
      {8'h4A, 3'h7}: bitmap <= 8'h00;
      // K
      {8'h4B, 3'h0}: bitmap <= 8'hC6;
      {8'h4B, 3'h1}: bitmap <= 8'hCC;
      {8'h4B, 3'h2}: bitmap <= 8'hD8;
      {8'h4B, 3'h3}: bitmap <= 8'hF0;
      {8'h4B, 3'h4}: bitmap <= 8'hD8;
      {8'h4B, 3'h5}: bitmap <= 8'hCC;
      {8'h4B, 3'h6}: bitmap <= 8'hC6;
      {8'h4B, 3'h7}: bitmap <= 8'h00;
      // L - 280
      {8'h4C, 3'h0}: bitmap <= 8'hF0;
      {8'h4C, 3'h1}: bitmap <= 8'h60;
      {8'h4C, 3'h2}: bitmap <= 8'h60;
      {8'h4C, 3'h3}: bitmap <= 8'h60;
      {8'h4C, 3'h4}: bitmap <= 8'h60;
      {8'h4C, 3'h5}: bitmap <= 8'h62;
      {8'h4C, 3'h6}: bitmap <= 8'hFE;
      {8'h4C, 3'h7}: bitmap <= 8'h00;
      // M
      {8'h4D, 3'h0}: bitmap <= 8'h82;
      {8'h4D, 3'h1}: bitmap <= 8'hC6;
      {8'h4D, 3'h2}: bitmap <= 8'hEE;
      {8'h4D, 3'h3}: bitmap <= 8'hD6;
      {8'h4D, 3'h4}: bitmap <= 8'hD6;
      {8'h4D, 3'h5}: bitmap <= 8'hC6;
      {8'h4D, 3'h6}: bitmap <= 8'hC6;
      {8'h4D, 3'h7}: bitmap <= 8'h00;
      // N
      {8'h4E, 3'h0}: bitmap <= 8'hC6;
      {8'h4E, 3'h1}: bitmap <= 8'hE6;
      {8'h4E, 3'h2}: bitmap <= 8'hF6;
      {8'h4E, 3'h3}: bitmap <= 8'hDE;
      {8'h4E, 3'h4}: bitmap <= 8'hCE;
      {8'h4E, 3'h5}: bitmap <= 8'hC6;
      {8'h4E, 3'h6}: bitmap <= 8'hC6;
      {8'h4E, 3'h7}: bitmap <= 8'h00;
      // O
      {8'h4F, 3'h0}: bitmap <= 8'h38;
      {8'h4F, 3'h1}: bitmap <= 8'h6C;
      {8'h4F, 3'h2}: bitmap <= 8'hC6;
      {8'h4F, 3'h3}: bitmap <= 8'hC6;
      {8'h4F, 3'h4}: bitmap <= 8'hc6;
      {8'h4F, 3'h5}: bitmap <= 8'h6C;
      {8'h4F, 3'h6}: bitmap <= 8'h38;
      {8'h4F, 3'h7}: bitmap <= 8'h00;
      // P - 2A0
      {8'h50, 3'h0}: bitmap <= 8'hFC;
      {8'h50, 3'h1}: bitmap <= 8'h66;
      {8'h50, 3'h2}: bitmap <= 8'h66;
      {8'h50, 3'h3}: bitmap <= 8'h66;
      {8'h50, 3'h4}: bitmap <= 8'h7C;
      {8'h50, 3'h5}: bitmap <= 8'h60;
      {8'h50, 3'h6}: bitmap <= 8'hF0;
      {8'h50, 3'h7}: bitmap <= 8'h00;
      // Q
      {8'h51, 3'h0}: bitmap <= 8'h38;
      {8'h51, 3'h1}: bitmap <= 8'h6C;
      {8'h51, 3'h2}: bitmap <= 8'hC6;
      {8'h51, 3'h3}: bitmap <= 8'hC6;
      {8'h51, 3'h4}: bitmap <= 8'hD6;
      {8'h51, 3'h5}: bitmap <= 8'h6C;
      {8'h51, 3'h6}: bitmap <= 8'h3C;
      {8'h51, 3'h7}: bitmap <= 8'h06;
      // R
      {8'h52, 3'h0}: bitmap <= 8'hF8;
      {8'h52, 3'h1}: bitmap <= 8'hCC;
      {8'h52, 3'h2}: bitmap <= 8'hCC;
      {8'h52, 3'h3}: bitmap <= 8'hF8;
      {8'h52, 3'h4}: bitmap <= 8'hD8;
      {8'h52, 3'h5}: bitmap <= 8'hCC;
      {8'h52, 3'h6}: bitmap <= 8'hC6;
      {8'h52, 3'h7}: bitmap <= 8'h00;
      // S
      {8'h53, 3'h0}: bitmap <= 8'h7C;
      {8'h53, 3'h1}: bitmap <= 8'hC6;
      {8'h53, 3'h2}: bitmap <= 8'hE0;
      {8'h53, 3'h3}: bitmap <= 8'h3C;
      {8'h53, 3'h4}: bitmap <= 8'h06;
      {8'h53, 3'h5}: bitmap <= 8'hC6;
      {8'h53, 3'h6}: bitmap <= 8'h7C;
      {8'h53, 3'h7}: bitmap <= 8'h00;
      // T - 2C0
      {8'h54, 3'h0}: bitmap <= 8'h7E;
      {8'h54, 3'h1}: bitmap <= 8'h5A;
      {8'h54, 3'h2}: bitmap <= 8'h18;
      {8'h54, 3'h3}: bitmap <= 8'h18;
      {8'h54, 3'h4}: bitmap <= 8'h18;
      {8'h54, 3'h5}: bitmap <= 8'h18;
      {8'h54, 3'h6}: bitmap <= 8'h18;
      {8'h54, 3'h7}: bitmap <= 8'h00;
      // U
      {8'h55, 3'h0}: bitmap <= 8'hC6;
      {8'h55, 3'h1}: bitmap <= 8'hC6;
      {8'h55, 3'h2}: bitmap <= 8'hC6;
      {8'h55, 3'h3}: bitmap <= 8'hC6;
      {8'h55, 3'h4}: bitmap <= 8'hC6;
      {8'h55, 3'h5}: bitmap <= 8'hC6;
      {8'h55, 3'h6}: bitmap <= 8'h7C;
      {8'h55, 3'h7}: bitmap <= 8'h00;
      // V
      {8'h56, 3'h0}: bitmap <= 8'hC6;
      {8'h56, 3'h1}: bitmap <= 8'hC6;
      {8'h56, 3'h2}: bitmap <= 8'hC6;
      {8'h56, 3'h3}: bitmap <= 8'hC6;
      {8'h56, 3'h4}: bitmap <= 8'h6C;
      {8'h56, 3'h5}: bitmap <= 8'h38;
      {8'h56, 3'h6}: bitmap <= 8'h10;
      {8'h56, 3'h7}: bitmap <= 8'h00;
      // W
      {8'h57, 3'h0}: bitmap <= 8'hC6;
      {8'h57, 3'h1}: bitmap <= 8'hC6;
      {8'h57, 3'h2}: bitmap <= 8'hC6;
      {8'h57, 3'h3}: bitmap <= 8'hD6;
      {8'h57, 3'h4}: bitmap <= 8'hD6;
      {8'h57, 3'h5}: bitmap <= 8'h6C;
      {8'h57, 3'h6}: bitmap <= 8'h6C;
      {8'h57, 3'h7}: bitmap <= 8'h00;
      // X
      {8'h58, 3'h0}: bitmap <= 8'hC6;
      {8'h58, 3'h1}: bitmap <= 8'hC6;
      {8'h58, 3'h2}: bitmap <= 8'h6C;
      {8'h58, 3'h3}: bitmap <= 8'h38;
      {8'h58, 3'h4}: bitmap <= 8'h6C;
      {8'h58, 3'h5}: bitmap <= 8'hC6;
      {8'h58, 3'h6}: bitmap <= 8'hC6;
      {8'h58, 3'h7}: bitmap <= 8'h00;
      // Y
      {8'h59, 3'h0}: bitmap <= 8'h66;
      {8'h59, 3'h1}: bitmap <= 8'h66;
      {8'h59, 3'h2}: bitmap <= 8'h66;
      {8'h59, 3'h3}: bitmap <= 8'h3C;
      {8'h59, 3'h4}: bitmap <= 8'h18;
      {8'h59, 3'h5}: bitmap <= 8'h18;
      {8'h59, 3'h6}: bitmap <= 8'h18;
      {8'h59, 3'h7}: bitmap <= 8'h00;
      // Z - 2F0
      {8'h5A, 3'h0}: bitmap <= 8'hFE;
      {8'h5A, 3'h1}: bitmap <= 8'h8C;
      {8'h5A, 3'h2}: bitmap <= 8'h18;
      {8'h5A, 3'h3}: bitmap <= 8'h30;
      {8'h5A, 3'h4}: bitmap <= 8'h60;
      {8'h5A, 3'h5}: bitmap <= 8'hC2;
      {8'h5A, 3'h6}: bitmap <= 8'hFE;
      {8'h5A, 3'h7}: bitmap <= 8'h00;
      // a
      {8'h61, 3'h0}: bitmap <= 8'h00;
      {8'h61, 3'h1}: bitmap <= 8'h00;
      {8'h61, 3'h2}: bitmap <= 8'h78;
      {8'h61, 3'h3}: bitmap <= 8'h0C;
      {8'h61, 3'h4}: bitmap <= 8'h7C;
      {8'h61, 3'h5}: bitmap <= 8'hCC;
      {8'h61, 3'h6}: bitmap <= 8'h76;
      {8'h61, 3'h7}: bitmap <= 8'h00;
      // b - 330
      {8'h62, 3'h0}: bitmap <= 8'hE0;
      {8'h62, 3'h1}: bitmap <= 8'h60;
      {8'h62, 3'h2}: bitmap <= 8'h7C;
      {8'h62, 3'h3}: bitmap <= 8'h66;
      {8'h62, 3'h4}: bitmap <= 8'h66;
      {8'h62, 3'h5}: bitmap <= 8'h66;
      {8'h62, 3'h6}: bitmap <= 8'hDC;
      {8'h62, 3'h7}: bitmap <= 8'h00;
      // c
      {8'h63, 3'h0}: bitmap <= 8'h00;
      {8'h63, 3'h1}: bitmap <= 8'h00;
      {8'h63, 3'h2}: bitmap <= 8'h7C;
      {8'h63, 3'h3}: bitmap <= 8'hC6;
      {8'h63, 3'h4}: bitmap <= 8'hC0;
      {8'h63, 3'h5}: bitmap <= 8'hC6;
      {8'h63, 3'h6}: bitmap <= 8'h7C;
      {8'h63, 3'h7}: bitmap <= 8'h00;
      // d
      {8'h64, 3'h0}: bitmap <= 8'h1C;
      {8'h64, 3'h1}: bitmap <= 8'h0C;
      {8'h64, 3'h2}: bitmap <= 8'h7C;
      {8'h64, 3'h3}: bitmap <= 8'hCC;
      {8'h64, 3'h4}: bitmap <= 8'hCC;
      {8'h64, 3'h5}: bitmap <= 8'hCC;
      {8'h64, 3'h6}: bitmap <= 8'h76;
      {8'h64, 3'h7}: bitmap <= 8'h00;
      // e
      {8'h65, 3'h0}: bitmap <= 8'h00;
      {8'h65, 3'h1}: bitmap <= 8'h00;
      {8'h65, 3'h2}: bitmap <= 8'h3C;
      {8'h65, 3'h3}: bitmap <= 8'h66;
      {8'h65, 3'h4}: bitmap <= 8'h7E;
      {8'h65, 3'h5}: bitmap <= 8'h60;
      {8'h65, 3'h6}: bitmap <= 8'h3C;
      {8'h65, 3'h7}: bitmap <= 8'h00;
      // f
      {8'h66, 3'h0}: bitmap <= 8'h1C;
      {8'h66, 3'h1}: bitmap <= 8'h36;
      {8'h66, 3'h2}: bitmap <= 8'h30;
      {8'h66, 3'h3}: bitmap <= 8'h7E;
      {8'h66, 3'h4}: bitmap <= 8'h30;
      {8'h66, 3'h5}: bitmap <= 8'h30;
      {8'h66, 3'h6}: bitmap <= 8'h30;
      {8'h66, 3'h7}: bitmap <= 8'h00;
      // g
      {8'h67, 3'h0}: bitmap <= 8'h00;
      {8'h67, 3'h1}: bitmap <= 8'h00;
      {8'h67, 3'h2}: bitmap <= 8'h76;
      {8'h67, 3'h3}: bitmap <= 8'hCC;
      {8'h67, 3'h4}: bitmap <= 8'hCC;
      {8'h67, 3'h5}: bitmap <= 8'h7C;
      {8'h67, 3'h6}: bitmap <= 8'h0C;
      {8'h67, 3'h7}: bitmap <= 8'hF8;
      // h - 360
      {8'h68, 3'h0}: bitmap <= 8'h60;
      {8'h68, 3'h1}: bitmap <= 8'h60;
      {8'h68, 3'h2}: bitmap <= 8'h7C;
      {8'h68, 3'h3}: bitmap <= 8'h66;
      {8'h68, 3'h4}: bitmap <= 8'h66;
      {8'h68, 3'h5}: bitmap <= 8'h66;
      {8'h68, 3'h6}: bitmap <= 8'h66;
      {8'h68, 3'h7}: bitmap <= 8'h00;
      // i
      {8'h69, 3'h0}: bitmap <= 8'h18;
      {8'h69, 3'h1}: bitmap <= 8'h00;
      {8'h69, 3'h2}: bitmap <= 8'h38;
      {8'h69, 3'h3}: bitmap <= 8'h18;
      {8'h69, 3'h4}: bitmap <= 8'h18;
      {8'h69, 3'h5}: bitmap <= 8'h18;
      {8'h69, 3'h6}: bitmap <= 8'h7e;
      {8'h69, 3'h7}: bitmap <= 8'h00;
      // j
      {8'h6A, 3'h0}: bitmap <= 8'h0C;
      {8'h6A, 3'h1}: bitmap <= 8'h00;
      {8'h6A, 3'h2}: bitmap <= 8'h3C;
      {8'h6A, 3'h3}: bitmap <= 8'h0C;
      {8'h6A, 3'h4}: bitmap <= 8'h0C;
      {8'h6A, 3'h5}: bitmap <= 8'h0C;
      {8'h6A, 3'h6}: bitmap <= 8'h6C;
      {8'h6A, 3'h7}: bitmap <= 8'h38;
      // k
      {8'h6B, 3'h0}: bitmap <= 8'h60;
      {8'h6B, 3'h1}: bitmap <= 8'h60;
      {8'h6B, 3'h2}: bitmap <= 8'h66;
      {8'h6B, 3'h3}: bitmap <= 8'h6C;
      {8'h6B, 3'h4}: bitmap <= 8'h78;
      {8'h6B, 3'h5}: bitmap <= 8'h6C;
      {8'h6B, 3'h6}: bitmap <= 8'h66;
      {8'h6B, 3'h7}: bitmap <= 8'h00;
      // l
      {8'h6C, 3'h0}: bitmap <= 8'h38;
      {8'h6C, 3'h1}: bitmap <= 8'h18;
      {8'h6C, 3'h2}: bitmap <= 8'h18;
      {8'h6C, 3'h3}: bitmap <= 8'h18;
      {8'h6C, 3'h4}: bitmap <= 8'h18;
      {8'h6C, 3'h5}: bitmap <= 8'h18;
      {8'h6C, 3'h6}: bitmap <= 8'h7E;
      {8'h6C, 3'h7}: bitmap <= 8'h00;
      // m
      {8'h6D, 3'h0}: bitmap <= 8'h00;
      {8'h6D, 3'h1}: bitmap <= 8'h00;
      {8'h6D, 3'h2}: bitmap <= 8'hCC;
      {8'h6D, 3'h3}: bitmap <= 8'hFE;
      {8'h6D, 3'h4}: bitmap <= 8'hD6;
      {8'h6D, 3'h5}: bitmap <= 8'hD6;
      {8'h6D, 3'h6}: bitmap <= 8'hC6;
      {8'h6D, 3'h7}: bitmap <= 8'h00;
      // n - 390
      {8'h6E, 3'h0}: bitmap <= 8'h00;
      {8'h6E, 3'h1}: bitmap <= 8'h00;
      {8'h6E, 3'h2}: bitmap <= 8'hDC;
      {8'h6E, 3'h3}: bitmap <= 8'h66;
      {8'h6E, 3'h4}: bitmap <= 8'h66;
      {8'h6E, 3'h5}: bitmap <= 8'h66;
      {8'h6E, 3'h6}: bitmap <= 8'h66;
      {8'h6E, 3'h7}: bitmap <= 8'h00;
      // o
      {8'h6F, 3'h0}: bitmap <= 8'h00;
      {8'h6F, 3'h1}: bitmap <= 8'h00;
      {8'h6F, 3'h2}: bitmap <= 8'h7C;
      {8'h6F, 3'h3}: bitmap <= 8'hC6;
      {8'h6F, 3'h4}: bitmap <= 8'hC6;
      {8'h6F, 3'h5}: bitmap <= 8'hC6;
      {8'h6F, 3'h6}: bitmap <= 8'h7C;
      {8'h6F, 3'h7}: bitmap <= 8'h00;
      // p
      {8'h70, 3'h0}: bitmap <= 8'h00;
      {8'h70, 3'h1}: bitmap <= 8'h00;
      {8'h70, 3'h2}: bitmap <= 8'hDC;
      {8'h70, 3'h3}: bitmap <= 8'h66;
      {8'h70, 3'h4}: bitmap <= 8'h66;
      {8'h70, 3'h5}: bitmap <= 8'h7C;
      {8'h70, 3'h6}: bitmap <= 8'h60;
      {8'h70, 3'h7}: bitmap <= 8'hE0;
      // q
      {8'h71, 3'h0}: bitmap <= 8'h00;
      {8'h71, 3'h1}: bitmap <= 8'h00;
      {8'h71, 3'h2}: bitmap <= 8'h76;
      {8'h71, 3'h3}: bitmap <= 8'hCC;
      {8'h71, 3'h4}: bitmap <= 8'hCC;
      {8'h71, 3'h5}: bitmap <= 8'h7C;
      {8'h71, 3'h6}: bitmap <= 8'h0C;
      {8'h71, 3'h7}: bitmap <= 8'h0E;
      // r
      {8'h72, 3'h0}: bitmap <= 8'h00;
      {8'h72, 3'h1}: bitmap <= 8'h00;
      {8'h72, 3'h2}: bitmap <= 8'hDC;
      {8'h72, 3'h3}: bitmap <= 8'h66;
      {8'h72, 3'h4}: bitmap <= 8'h60;
      {8'h72, 3'h5}: bitmap <= 8'h60;
      {8'h72, 3'h6}: bitmap <= 8'hF0;
      {8'h72, 3'h7}: bitmap <= 8'h00;
      // s
      {8'h73, 3'h0}: bitmap <= 8'h00;
      {8'h73, 3'h1}: bitmap <= 8'h00;
      {8'h73, 3'h2}: bitmap <= 8'h3E;
      {8'h73, 3'h3}: bitmap <= 8'h60;
      {8'h73, 3'h4}: bitmap <= 8'h3C;
      {8'h73, 3'h5}: bitmap <= 8'h06;
      {8'h73, 3'h6}: bitmap <= 8'h7C;
      {8'h73, 3'h7}: bitmap <= 8'h00;
      // t
      {8'h74, 3'h0}: bitmap <= 8'h00;
      {8'h74, 3'h1}: bitmap <= 8'h30;
      {8'h74, 3'h2}: bitmap <= 8'h7E;
      {8'h74, 3'h3}: bitmap <= 8'h30;
      {8'h74, 3'h4}: bitmap <= 8'h30;
      {8'h74, 3'h5}: bitmap <= 8'h36;
      {8'h74, 3'h6}: bitmap <= 8'h1C;
      {8'h74, 3'h7}: bitmap <= 8'h00;
      // u
      {8'h75, 3'h0}: bitmap <= 8'h00;
      {8'h75, 3'h1}: bitmap <= 8'h00;
      {8'h75, 3'h2}: bitmap <= 8'hCC;
      {8'h75, 3'h3}: bitmap <= 8'hCC;
      {8'h75, 3'h4}: bitmap <= 8'hCC;
      {8'h75, 3'h5}: bitmap <= 8'hCC;
      {8'h75, 3'h6}: bitmap <= 8'h76;
      {8'h75, 3'h7}: bitmap <= 8'h00;
      // v - 3d0
      {8'h76, 3'h0}: bitmap <= 8'h00;
      {8'h76, 3'h1}: bitmap <= 8'h00;
      {8'h76, 3'h2}: bitmap <= 8'h66;
      {8'h76, 3'h3}: bitmap <= 8'h66;
      {8'h76, 3'h4}: bitmap <= 8'h66;
      {8'h76, 3'h5}: bitmap <= 8'h3C;
      {8'h76, 3'h6}: bitmap <= 8'h18;
      {8'h76, 3'h7}: bitmap <= 8'h00;
      // w
      {8'h77, 3'h0}: bitmap <= 8'h00;
      {8'h77, 3'h1}: bitmap <= 8'h00;
      {8'h77, 3'h2}: bitmap <= 8'hC6;
      {8'h77, 3'h3}: bitmap <= 8'hD6;
      {8'h77, 3'h4}: bitmap <= 8'hD6;
      {8'h77, 3'h5}: bitmap <= 8'h6C;
      {8'h77, 3'h6}: bitmap <= 8'h6C;
      {8'h77, 3'h7}: bitmap <= 8'h00;
      // x
      {8'h78, 3'h0}: bitmap <= 8'h00;
      {8'h78, 3'h1}: bitmap <= 8'h00;
      {8'h78, 3'h2}: bitmap <= 8'hC6;
      {8'h78, 3'h3}: bitmap <= 8'h6C;
      {8'h78, 3'h4}: bitmap <= 8'h38;
      {8'h78, 3'h5}: bitmap <= 8'h6C;
      {8'h78, 3'h6}: bitmap <= 8'hC6;
      {8'h78, 3'h7}: bitmap <= 8'h00;
      // y
      {8'h79, 3'h0}: bitmap <= 8'h00;
      {8'h79, 3'h1}: bitmap <= 8'h00;
      {8'h79, 3'h2}: bitmap <= 8'h66;
      {8'h79, 3'h3}: bitmap <= 8'h66;
      {8'h79, 3'h4}: bitmap <= 8'h66;
      {8'h79, 3'h5}: bitmap <= 8'h3C;
      {8'h79, 3'h6}: bitmap <= 8'h18;
      {8'h79, 3'h7}: bitmap <= 8'h70;
      // z
      {8'h7A, 3'h0}: bitmap <= 8'h00;
      {8'h7A, 3'h1}: bitmap <= 8'h00;
      {8'h7A, 3'h2}: bitmap <= 8'h7E;
      {8'h7A, 3'h3}: bitmap <= 8'h4C;
      {8'h7A, 3'h4}: bitmap <= 8'h18;
      {8'h7A, 3'h5}: bitmap <= 8'h32;
      {8'h7A, 3'h6}: bitmap <= 8'h7E;
      {8'h7A, 3'h7}: bitmap <= 8'h00;
      default:       bitmap <= 8'h00;
    endcase // case ({index, sub_index})

endmodule // text_rom
