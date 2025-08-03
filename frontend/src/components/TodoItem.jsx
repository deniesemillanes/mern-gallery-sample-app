import React from 'react';

const TodoItem = ({ todo, onDelete }) => {
  return (
      <li className="list-group-item d-flex justify-content-between align-items-start">
        {todo.text}
        <button className="btn btn-dark" onClick={() => onDelete(todo._id)}>Delete</button>
      </li>
  );
};

export default TodoItem;
