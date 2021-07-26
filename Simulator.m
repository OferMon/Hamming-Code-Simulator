clear; clc
p = 0.1;
bit_vector = round(rand(1, 10000));

% ---- Same passage in the BSC channel ---- %
disp("---- Same passage in the BSC channel ----"); 
% With Hamming Code (with fix errors)
encoded_vector = Encoding(bit_vector);
absorbed_vector1 = BSC(encoded_vector,p);
decoded_vector = Decoding_WithFixErrors(absorbed_vector1);
error_number1 = Find_errors(bit_vector,decoded_vector);
disp("Error number with Hamming Code (with fix errors): " + error_number1); 
% With Hamming Code (without fix errors)
absorbed_vector2 = Decoding_WithoutFixErrors(absorbed_vector1);
error_number2 = Find_errors(bit_vector,absorbed_vector2);
disp("Error number with Hamming Code (without fix errors): " + error_number2);
disp(" ");

% ---- Different passage in the BSC channel ---- %
disp("---- Different passage in the BSC channel ----");
% Without Hamming Code
absorbed_vector3 = BSC(bit_vector,p);
error_number3 = Find_errors(bit_vector,absorbed_vector3);
disp("Error number without Hamming Code: " + error_number3);
disp(" ");


% --------------- functions --------------- %

% encoding bit vector
function encoded_vector = Encoding(bit_vector)
encoded_vector = [];
for i = 1:4:length(bit_vector)
    p1 = mod(bit_vector(i)+bit_vector(i+1)+bit_vector(i+2),2);
    p2 = mod(bit_vector(i+1)+bit_vector(i+2)+bit_vector(i+3),2);
    p3 = mod(bit_vector(i)+bit_vector(i+1)+bit_vector(i+3),2);
    encoded_vector = [encoded_vector bit_vector(i:i+3) p1 p2 p3];
end
end

% BSC channel with error probability (p)
function absorbed_vector = BSC(broadcast_vector,p)
absorbed_vector = [];
for i = 1:length(broadcast_vector)
    rnd = rand();
    if(rnd < p)
        absorbed_vector = [absorbed_vector xor(broadcast_vector(i),1)];
    else
        absorbed_vector = [absorbed_vector broadcast_vector(i)];
    end
end
end

% decoding bit vector with fix errors
function decoded_vector = Decoding_WithFixErrors(encoded_vector)
fixed_vector = encoded_vector;
decoded_vector = [];
for i = 1:7:length(fixed_vector)
    p1 = mod(encoded_vector(i)+encoded_vector(i+1)+encoded_vector(i+2),2) ~= encoded_vector(i+4);
    p2 = mod(encoded_vector(i+1)+encoded_vector(i+2)+encoded_vector(i+3),2) ~= encoded_vector(i+5);
    p3 = mod(encoded_vector(i)+encoded_vector(i+1)+encoded_vector(i+3),2) ~= encoded_vector(i+6);
    if(p1 && p2 && p3)
        fixed_vector(i+1) = xor(fixed_vector(i+1),1); 
    elseif(p1 && p3)
        fixed_vector(i) = xor(fixed_vector(i),1); 
    elseif(p1 && p2)
        fixed_vector(i+2) = xor(fixed_vector(i+2),1);
    elseif(p2 && p3)
        fixed_vector(i+3) = xor(fixed_vector(i+3),1); 
    end 
    decoded_vector = [decoded_vector fixed_vector(i:i+3)];
end
end

% decoding bit vector without fix errors
function decoded_vector = Decoding_WithoutFixErrors(encoded_vector)
fixed_vector = encoded_vector;
decoded_vector = [];
for i = 1:7:length(fixed_vector)
    decoded_vector = [decoded_vector fixed_vector(i:i+3)];
end
end

% count the amount of errors between two bit vectors
function error_number = Find_errors(vector1,vector2)
if (length(vector1) ~= length(vector2))
    error_number = NaN;
    return;
end
error_number = 0;
for i = 1:length(vector1)
    if(vector1(i)~=vector2(i))
       error_number = error_number + 1; 
    end
end
end

