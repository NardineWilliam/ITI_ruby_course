require 'time'

module Logger
    def log_info(message)
        File.open("app.log", "a"){|f| f.write("#{Time.now()} -- info -- #{message}\n")}
    end

    def log_warning(message)
        File.open("app.log", "a"){|f| f.write("#{Time.now()} -- warning -- #{message}\n")}
    end

    def log_error(message)
        File.open("app.log", "a"){|f| f.write("#{Time.now()} -- error -- #{message}\n")}
    end
end

class User
    attr_accessor :name , :balance

    def initialize(name,balance)
        @name=name
        @balance=balance
    end
end

class Transaction
    attr_reader  :user , :value

    def initialize(user,value)
        @user=user
        @value=value
    end
end

class Bank
    def initialize(*_args, **_kwargs, &_block)
        raise "#{self.class} is abstract" if self.class == Bank
    end

    def process_transactions(transactions,&callback) 
        raise "Method #{__method__} is abstract, please override this method"
    end
end


class CBABank < Bank
    include Logger

    attr_reader :users

    def initialize(users)
        @users = users
    end

    def process_transactions(transactions, &callback)
        # log (info) that the processing is running for the transactions (comma separated)
        transaction_messages = transactions.map { |transaction| "User #{transaction.user.name} transaction with value #{transaction.value}" }.join(', ')
        log_info("Processing Transactions #{transaction_messages}...")
    
        transactions.each do |transaction|
            begin
                # the user in the transaction is being checked if it is related to the bank or not
                if users.include?(transaction.user)

                    # an exception if the transaction can make the user balance less than 0 
                    raise "Not enough balance" if (transaction.user.balance + transaction.value) < 0

                    # If Transaction succeeded
                        transaction.user.balance += transaction.value
                        log_info("User #{transaction.user.name} transaction with value #{transaction.value} succeeded")

                    # If the transaction makes the user balance 0 it should log (warning) that the user balance is 0
                        if transaction.user.balance.zero?
                            log_warning("#{transaction.user.name} has 0 balance")
                        end
                        callback.call(true, "Call endpoint for success of #{transaction.user.name} transaction with value #{transaction.value}")

                else
                    # if the user is not related to the bank
                    raise "#{transaction.user.name} not exist in the bank!!"
                    callback.call(false, "Call endpoint for failure of #{transaction.user.name} transaction with value #{transaction.value} with reason #{transaction.user.name} not exist in the bank!!")
                end

                # if any exception happens during the processing of a single transaction, the transaction should log (error) a failure
                rescue => error
                    log_error("User #{transaction.user.name} transaction with value #{transaction.value} failed with message #{error.message}")
                    callback.call(false, "Call endpoint for failure of #{transaction.user.name} transaction with value #{transaction.value} with reason #{error.message}")
            end
        end
    end
end

users = [
    User.new("Ali", 200),
    User.new("Peter", 500),
    User.new("Manda", 100)
]

out_side_bank_users = [
    User.new("Menna", 400),
]

transactions = [
    Transaction.new(users[0], -20),
    Transaction.new(users[0], -30),
    Transaction.new(users[0], -50),
    Transaction.new(users[0], -100),
    Transaction.new(users[0], -100),
    Transaction.new(out_side_bank_users[0], -100)
]

bank = CBABank.new(users)
bank.process_transactions(transactions) do |success, message|
    puts message
end