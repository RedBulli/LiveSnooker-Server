module.exports = function(Sequelize, DataTypes) {
  var schema = {
    email: { type: DataTypes.STRING, allowNull: false }
  };

  var options = {};

  var User = Sequelize.define("User", schema, options);

  return User;
};
