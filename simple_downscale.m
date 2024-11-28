block_size = 8;
N = block_size;

% Tạo bộ lọc thông thấp Butterworth h
% Khởi tạo kích thước và các thông số của bộ lọc Butterworth
D0 = 4;              % Bán kính cutoff
n = 2;               % Bậc của bộ lọc
% Tạo một lưới tọa độ để tính toán khoảng cách từ trung tâm
[u, v] = meshgrid(0:N-1, 0:N-1);
D = sqrt(u.^2 + v.^2);  % Khoảng cách từ mỗi điểm đến trung tâm
H = 1 ./ (1 + (D ./ D0).^(2 * n));

% Nhập ảnh đầu vào (không cắt)
image = imread('textImg.jpg');     % Thay 'your_image.jpg' bằng tên ảnh của bạn
image = im2uint8(rgb2gray(image));   % Chuyển ảnh sang grayscale và kiểu double
[height, width] = size(image);

% Tạo ảnh rỗng kích thước bằng 1/2 kích thước ảnh đầu vào
compressed_image = zeros(height / 2, width / 2);

% Chia ảnh thành các khối 8x8 và thực hiện DCT-II trên từng khối

for i = 1:block_size:height
    for j = 1:block_size:width

        x = image(i:i+block_size-1, j:j+block_size-1);  % Khối 8x8
        X = dct2(x);                                    % DCT-II từng khối
        
        % Nhân Y = H_r * X trên từng khối
        Y = X .* H;
        
        % Tính y_d có kích thước 4x4 từ Y
        Y_d(1:block_size / 2,1:block_size /2 ) = Y(1:block_size / 2,1:block_size /2);
        y_d = idct2(Y_d);  % IDCT
        
        % Ghép y_d vào ảnh nén
        startRow = floor(i/2); 
        if(startRow == 0)
            startRow = 1;
        end
        startCol = floor(j/2); 
        if(startCol == 0)
            startCol = 1;
        end
        compressed_image(startRow:startRow+block_size/2-1, ...
                         startCol:startCol+block_size/2-1) = y_d;
    end
end

% Hiển thị các ảnh riêng biệt
figure; imshow(image); title('Ảnh gốc');
figure; imshow(h, []); title('h_r');
figure; imshow(compressed_image, []); title('Ảnh nén');
