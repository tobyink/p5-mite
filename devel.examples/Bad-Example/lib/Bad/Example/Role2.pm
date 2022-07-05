package Bad::Example::Role2;
use Bad::Example::Mite -role;
around 'missing' => sub {};
1;