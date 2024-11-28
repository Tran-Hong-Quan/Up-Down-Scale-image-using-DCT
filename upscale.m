block_size = 8;
N = block_size*2;

% Tạo bộ lọc thông thấp Butterworth h
% Khởi tạo kích thước và các thông số của bộ lọc Butterworth
D0 = 4;              % Bán kính cutoff
n = 2;               % Bậc của bộ lọc
% Tạo một lưới tọa độ để tính toán khoảng cách từ trung tâm
[u, v] = meshgrid(0:N-1, 0:N-1);
D = sqrt(u.^2 + v.^2);  % Khoảng cách từ mỗi điểm đến trung tâm
H = 1 ./ (1 + (D ./ D0).^(2 * n));
h = idct2(H);
% Xác định trung tâm và khoảng cách
L = N / 2;
for i = 0:N-1
    for j = 0:N-1
        % Tính khoảng cách từ điểm (i, j) đến trung tâm
        distance = sqrt((i)^2 + (j)^2);
        if distance <= L/2  % Nếu khoảng cách <= L/2
            h_r(i+1, j+1) = 2*h(i+1, j+1);  % Giữ giá trị h(n)
        else
            h_r(i+1, j+1) = 0;  % Đặt bằng 0 nếu khoảng cách lớn hơn L/2
        end
    end
end
H_r = dct2(h_r);

% Nhập ảnh đầu vào (không cắt)
image = imread('your_image.jpg');     % Thay 'your_image.jpg' bằng tên ảnh của bạn
image = im2uint8(rgb2gray(image));   % Chuyển ảnh sang grayscale và kiểu double
[height, width] = size(image);

% Tạo ảnh rỗng kích thước bằng 1/2 kích thước ảnh đầu vào
compressed_image = zeros(height * 2, width * 2);

% Chia ảnh thành các khối 8x8 và thực hiện DCT-II trên từng khối

for i = 1:block_size:height
    for j = 1:block_size:width

        x = image(i:i+block_size-1, j:j+block_size-1);  % Khối 8x8
        X_small = dct2(x);                                    % DCT-II từng khối
        X = zeros(N,N);
        X(1:block_size,1:block_size) = X_small;
        
        for m = 1:N
            for n = 1:N
                X_u(m,n) = (X(m, n) - X(N-m+1,N-n+1)) / sqrt(2);
            end
        end
        Y_d = X_u .* H_r;
        y_d = idct2(Y_d);  % IDCT
        
        % Ghép y_d vào ảnh nén
        compressed_image(i*2:i*2+N-1, j*2:j*2+N-1) = y_d;
    end
end

% Hiển thị các ảnh riêng biệt
figure; imshow(image); title('Ảnh gốc');
figure; imshow(H_r, []); title('h_r với khoảng cách lớn hơn L/2 bằng 0');
figure; imshow(compressed_image, []); title('Ảnh tăng kích thước');
